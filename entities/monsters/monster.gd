extends CharacterBody2D

@export var stats: StatsData
@export var patrol_distance: float = 100.0
@export var attack_range: float = 70.0
@export var attack_cooldown: float = 1.5
@export var attack_hit_frame: int = 1 # เฟรมของท่า attack ที่ดาเมจเข้า
@export var projectile_scene: PackedScene # ใส่ = ตีไกล (ยิงจากตำแหน่ง AttackArea), ว่าง = ตีประชิด

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

	if is_dead:
		velocity.x = 0.0
		move_and_slide()
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
			velocity.x = direction * stats.move_speed
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
	velocity.x = direction * stats.move_speed

func _start_attack() -> void:
	is_attacking = true
	cooldown_timer = attack_cooldown

func _on_frame_changed() -> void:
	if sprite.animation != "attack" or sprite.frame != attack_hit_frame:
		return
	if projectile_scene:
		_shoot()
		return
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(stats.attack_power)

func _shoot() -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	projectile.direction = direction
	projectile.damage = stats.attack_power
	projectile.shooter = self
	projectile.position = position + attack_area.position
	get_parent().add_child(projectile)

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
	elif sprite.animation == "die":
		queue_free()

func _on_detect_entered(body: Node2D) -> void:
	target = body

func _on_detect_exited(body: Node2D) -> void:
	if body == target:
		target = null

func take_damage(amount: int) -> void:
	if is_dead:
		return
	stats.hp -= amount
	print("Monster took ", amount, " damage. HP: ", stats.hp, "/", stats.max_hp)
	if stats.hp <= 0:
		die()

func die() -> void:
	is_dead = true
	collision_layer = 0 # ตีซ้ำไม่ได้ ลูกธนูทะลุ
	detect_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	sprite.play("die")
