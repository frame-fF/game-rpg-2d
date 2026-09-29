extends CharacterBody2D

@export var stats: StatsData
@export var patrol_distance: float = 100.0
@export var attack_range: float = 70.0
@export var attack_cooldown: float = 1.5
@export var attack_hit_frame: int = 1 # เฟรมของท่า attack ที่ดาเมจเข้า
@export var projectile_scene: PackedScene # ใส่ = ตีไกล (ยิงจากตำแหน่ง AttackArea), ว่าง = ตีประชิด
@export var skills: Array[ActiveSkill] = [] # สกิลเสริม ใช้เมื่อ cooldown หมดและเป้าอยู่ในระยะสกิล
@export var passives: Array[PassiveSkill] = []
@export var skill_level: int = 1
@export var chase_distance: float = 400.0 # เป้าไกลกว่านี้ = เลิกไล่
@export var follow_distance: float = 60.0 # ลูกน้อง: ห่างเจ้าของเกินนี้ = เดินตาม

var team: String = "monster"
var effects: EffectHolder
var skill_cooldowns: Dictionary = {} # id สกิล -> วินาทีที่เหลือ (แยกต่อตัว)
var pending_skill: ActiveSkill        # สกิลที่จะออกตอนถึงเฟรมโจมตี
var leader: Node2D                    # เจ้าของ (ถ้าเป็นลูกน้องที่ถูกเสก)
var lifetime: float = 0.0             # ลูกน้อง: วินาทีที่เหลือ, 0 = อยู่จนตาย

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 1.0
var start_x: float
var target: Node2D
var is_attacking: bool = false
var is_dead: bool = false
var cooldown_timer: float = 0.0
var attack_box_x: float # ระยะกล่องโจมตีจากตัว อ่านจากตำแหน่ง AttackArea ใน scene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	stats = stats.duplicate()
	effects = EffectHolder.new()
	effects.name = "Effects"
	add_child(effects)
	for passive in passives:
		effects.add(passive.id, passive.skill_name, passive.effects, mini(skill_level, passive.max_level), -1.0)
	start_x = position.x
	attack_box_x = absf(attack_area.position.x)
	detect_area.body_entered.connect(_on_detect_entered)
	detect_area.body_exited.connect(_on_detect_exited)
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	for id in skill_cooldowns:
		skill_cooldowns[id] = maxf(skill_cooldowns[id] - delta, 0.0)
	if is_dead: # ตายแล้ว: ไม่หาเป้า/ไม่นับเวลา (Area ปิดไปแล้ว)
		velocity.x = 0.0
		move_and_slide()
		return

	if target and (not is_instance_valid(target) or target.get("is_dead") \
			or global_position.distance_to(target.global_position) > chase_distance):
		target = null
	if target == null:
		target = _find_target()
	if lifetime > 0.0:
		lifetime -= delta
		if lifetime <= 0.0:
			die()
			return

	if is_attacking:
		velocity.x = 0.0
	elif target:
		direction = signf(target.global_position.x - global_position.x)
		if absf(target.global_position.x - global_position.x) <= attack_range:
			velocity.x = 0.0
			if cooldown_timer <= 0.0:
				_start_attack()
		else:
			velocity.x = direction * get_stat("move_speed")
	elif leader and is_instance_valid(leader):
		_follow_leader()
	else:
		_patrol()

	move_and_slide()

	sprite.flip_h = direction < 0
	attack_area.position.x = attack_box_x * direction
	if is_attacking:
		sprite.play("attack")
	elif velocity.x != 0.0:
		sprite.play("walk")
	else:
		sprite.stop()

func _patrol() -> void:
	if is_on_wall():
		direction = -direction
	elif position.x > start_x + patrol_distance:
		direction = -1.0
	elif position.x < start_x - patrol_distance:
		direction = 1.0
	velocity.x = direction * get_stat("move_speed")

func _follow_leader() -> void:
	var dx := leader.global_position.x - global_position.x
	if absf(dx) > follow_distance:
		direction = signf(dx)
		velocity.x = direction * get_stat("move_speed")
	else:
		velocity.x = 0.0

# ศัตรูตัวแรกที่อยู่ในวงมองเห็น (ใช้ตอนเป้าเดิมตาย/หาย)
func _find_target() -> Node2D:
	for body in detect_area.get_overlapping_bodies():
		if Combat.is_enemy(self, body) and not body.get("is_dead"):
			return body
	return null

func _start_attack() -> void:
	is_attacking = true
	cooldown_timer = attack_cooldown
	pending_skill = _pick_skill()
	if pending_skill:
		skill_cooldowns[pending_skill.id] = pending_skill.cooldown

func _pick_skill() -> ActiveSkill:
	var dist := absf(target.global_position.x - global_position.x)
	for skill in skills:
		if skill_cooldowns.get(skill.id, 0.0) <= 0.0 and dist <= skill.skill_range:
			return skill
	return null

func _on_frame_changed() -> void:
	if sprite.animation != "attack" or sprite.frame != attack_hit_frame:
		return
	if pending_skill:
		pending_skill.use(self, mini(skill_level, pending_skill.max_level))
	elif projectile_scene:
		Combat.shoot(self, projectile_scene, get_attack_power(), get_attack_origin(), direction)
	else:
		Combat.hit_bodies(self, attack_area.get_overlapping_bodies(), get_attack_power())

func get_stat(stat: String) -> float:
	var value: float = stats.get(stat) + effects.stat_flat(stat)
	return maxf(value * (1.0 + effects.stat_percent(stat) / 100.0), 0.0)

# ที่สกิลเรียกใช้ (ผู้เล่นมีฟังก์ชันชื่อเดียวกัน)
func get_attack_power() -> int:
	return int(get_stat("attack_power"))

func get_facing() -> float:
	return direction

func get_attack_origin() -> Vector2:
	return position + attack_area.position

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
	elif sprite.animation == "die":
		queue_free()

func _on_detect_entered(body: Node2D) -> void:
	if target == null and Combat.is_enemy(self, body):
		target = body

func _on_detect_exited(body: Node2D) -> void:
	if body == target:
		target = null

func take_damage(amount: int, attacker: Node2D = null) -> void:
	if is_dead:
		return
	if attacker and Combat.is_enemy(self, attacker):
		target = attacker # โดนตีแล้วไล่คนตี แม้อยู่นอกระยะมองเห็น
	amount = maxi(1, amount - int(get_stat("defense")))
	stats.hp -= amount
	print("Monster took ", amount, " damage. HP: ", stats.hp, "/", stats.max_hp)
	if stats.hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	effects.clear()
	collision_layer = 0 # ตีซ้ำไม่ได้ ลูกธนูทะลุ
	detect_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	sprite.play("die")
