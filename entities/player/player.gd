extends CharacterBody2D

const WALK_ANIM_SPEED := 200.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.6
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@export var unarmed_range: float = 24.0
const ATTACK_START := 8.0
var attack_range: float = 0.0
var facing_direction: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var is_attacking: bool = false
var attack_anim: String = "attack"
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: StatsData
@onready var attack_area: Area2D = $AttackArea
@onready var armor_sprite: AnimatedSprite2D = $ArmorSprite
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var face_sprite: AnimatedSprite2D = $FaceSprite
@export var appearance: AppearanceData
@export var body_frames_male: SpriteFrames
@export var body_frames_female: SpriteFrames

@export var inventory: InventoryData
@export var skills: SkillSetData
@export var mp_regen: float = 2.0 # MP ต่อวินาที

var team: String = "player"
var _mp_regen_acc: float = 0.0

func _ready() -> void:
	inventory.equipment_changed.connect(_on_equipment_changed)
	animated_sprite.frame_changed.connect(_sync_layers)
	animated_sprite.animation_changed.connect(_sync_layers)
	appearance.changed.connect(_on_appearance_changed)
	_refresh_sprites()
	attack_shape.shape = attack_shape.shape.duplicate()
	_set_attack_range(unarmed_range)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= _delta
	skills.tick(_delta)
	_regen_mp(_delta)

	if not is_on_floor():
		velocity.y += gravity * _delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	var move_speed := stats.move_speed * inventory.get_move_speed()
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_direction = sign(direction)

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown

	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		_attack()
	for slot in 4:
		if Input.is_action_just_pressed("skill_%d" % (slot + 1)):
			_use_skill(slot)

	if is_dashing:
		velocity.x = facing_direction * dash_speed
		dash_timer -= _delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity.x = direction * move_speed

	move_and_slide()

	animated_sprite.flip_h = facing_direction < 0
	armor_sprite.flip_h = facing_direction < 0
	weapon_sprite.flip_h = facing_direction < 0
	face_sprite.flip_h = facing_direction < 0
	attack_area.position.x = (ATTACK_START + attack_range / 2) * facing_direction

	if is_dashing:
		animated_sprite.play("dash")
	elif is_attacking:
		animated_sprite.play(attack_anim, stats.attack_speed * inventory.get_attack_speed())
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk", move_speed / WALK_ANIM_SPEED)
	else:
		animated_sprite.play("idle")


func _attack() -> void:
	var damage := get_attack_power()
	var weapon := inventory.equipped.get("weapon") as WeaponData
	attack_anim = weapon.attack_animation if weapon else "attack"
	if weapon and weapon.attack_type == "projectile":
		Combat.shoot(self, weapon.projectile_scene, damage, get_attack_origin(), facing_direction, weapon.attack_range)
		return
	Combat.hit_bodies(self, attack_area.get_overlapping_bodies(), damage)

func _use_skill(slot: int) -> void:
	var skill: ActiveSkill = skills.hotbar[slot] if slot < skills.hotbar.size() else null
	if skill == null or is_attacking or not skills.is_ready(skill):
		return
	var level := skills.get_level(skill)
	var cost := skill.get_mp_cost(level)
	if stats.mp < cost:
		print("MP ไม่พอ: ", skill.skill_name)
		return
	stats.mp -= cost
	skills.start_cooldown(skill)
	is_attacking = true
	attack_anim = skill.animation
	skill.use(self, level)

func _regen_mp(delta: float) -> void:
	if stats.mp >= stats.max_mp:
		_mp_regen_acc = 0.0
		return
	_mp_regen_acc += mp_regen * delta
	if _mp_regen_acc >= 1.0:
		stats.mp = mini(stats.mp + int(_mp_regen_acc), stats.max_mp)
		_mp_regen_acc -= int(_mp_regen_acc)

# ที่สกิลเรียกใช้ (มอนมีฟังก์ชันชื่อเดียวกัน)
func get_attack_power() -> int:
	return stats.attack_power + inventory.get_attack_power_bonus()

func get_facing() -> float:
	return facing_direction

func get_attack_origin() -> Vector2:
	return position + Vector2(ATTACK_START * facing_direction, -10)


func take_damage(amount: int, _attacker: Node2D = null) -> void:
	var damage := maxi(1, amount - (stats.defense + inventory.get_defense_bonus()))
	stats.hp = maxi(stats.hp - damage, 0)
	print("Player took ", damage, " damage. HP: ", stats.hp, "/", stats.max_hp)
	if stats.hp == 0:
		print("Player died")


func _on_equipment_changed(slot: String, item: EquipmentData) -> void:
	if slot == "weapon":
		var weapon := item as WeaponData
		_set_attack_range(weapon.attack_range if weapon and weapon.attack_range > 0 else unarmed_range)
	_refresh_sprites()

func _on_appearance_changed() -> void:
	inventory.unequip_locked(appearance.gender)
	_refresh_sprites()
	
func _refresh_sprites() -> void:
	animated_sprite.sprite_frames = body_frames_female if appearance.gender == "female" else body_frames_male
	face_sprite.sprite_frames = _frames_of(appearance.face)
	armor_sprite.sprite_frames = _frames_of(inventory.equipped.get("armor"))
	weapon_sprite.sprite_frames = _frames_of(inventory.equipped.get("weapon"))
	_sync_layers()

func _frames_of(item: EquipmentData) -> SpriteFrames:
	return item.get_frames(appearance.gender) if item else null

func _sync_layers() -> void:
	for layer in [face_sprite, armor_sprite, weapon_sprite]:
		_sync_layer(layer)

func _sync_layer(layer: AnimatedSprite2D) -> void:
	var anim := animated_sprite.animation
	if layer.sprite_frames and layer.sprite_frames.has_animation(anim):
		layer.visible = true
		layer.animation = anim
		layer.frame = animated_sprite.frame
	else:
		layer.visible = false

func _set_attack_range(value: float) -> void:
	attack_range = value
	attack_shape.shape.size.x = value

func _on_animation_finished() -> void:
	if animated_sprite.animation == attack_anim:
		is_attacking = false
