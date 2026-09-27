extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.6
@export var attack_duration: float = 0.3
var facing_direction: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var is_attacking: bool = false
var attack_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: StatsData
@onready var attack_area: Area2D = $AttackArea
@onready var armor_sprite: AnimatedSprite2D = $ArmorSprite
@export var starting_armor: EquipmentData
@export var starting_weapon: EquipmentData
var equipped_weapon: EquipmentData
var equipped_armor: EquipmentData
var base_attack_power: int = 0
@export var inventory: InventoryData

func _ready() -> void:
	inventory.equip_requested.connect(equip)
	animated_sprite.frame_changed.connect(_sync_armor)
	animated_sprite.animation_changed.connect(_sync_armor)
	base_attack_power = stats.attack_power
	if starting_armor:
		equip_armor(starting_armor)
	if starting_weapon:
		equip_weapon(starting_weapon)

func _physics_process(_delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= _delta

	if not is_on_floor():
		velocity.y += gravity * _delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		facing_direction = sign(direction)

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown

	if attack_timer > 0.0:
		attack_timer -= _delta
		if attack_timer <= 0.0:
			is_attacking = false

	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		attack_timer = attack_duration
		_attack()

	if is_dashing:
		velocity.x = facing_direction * dash_speed
		dash_timer -= _delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity.x = direction * speed

	move_and_slide()

	animated_sprite.flip_h = facing_direction < 0
	armor_sprite.flip_h = facing_direction < 0
	attack_area.position.x = 20 * facing_direction



	if is_dashing:
		animated_sprite.play("dash")
	elif is_attacking:
		animated_sprite.play("attack")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")


func _attack() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(stats.attack_power)

func equip(item: EquipmentData) -> void:
	if item.slot == "weapon":
		equip_weapon(item)
	elif item.slot == "armor":
		equip_armor(item)

func equip_weapon(item: EquipmentData) -> void:
	equipped_weapon = item
	stats.attack_power = base_attack_power + item.attack_bonus

func equip_armor(item: EquipmentData) -> void:
	equipped_armor = item
	armor_sprite.sprite_frames = item.sprite_frames
	armor_sprite.visible = true
	_sync_armor()

func _sync_armor() -> void:
	if equipped_armor:
		armor_sprite.animation = animated_sprite.animation
		armor_sprite.frame = animated_sprite.frame
