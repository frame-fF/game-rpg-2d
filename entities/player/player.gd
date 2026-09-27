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
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var face_sprite: AnimatedSprite2D = $FaceSprite
@export var appearance: AppearanceData

var base_attack_power: int = 0
@export var inventory: InventoryData

func _ready() -> void:
	inventory.equipment_changed.connect(_on_equipment_changed)
	animated_sprite.frame_changed.connect(_sync_layers)
	animated_sprite.animation_changed.connect(_sync_layers)
	base_attack_power = stats.attack_power
	appearance.changed.connect(_apply_appearance)
	_apply_appearance()

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
	weapon_sprite.flip_h = facing_direction < 0
	face_sprite.flip_h = facing_direction < 0
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

func _on_equipment_changed(slot: String, item: EquipmentData) -> void:
	var frames: SpriteFrames = item.sprite_frames if item else null
	if slot == "weapon":
		stats.attack_power = base_attack_power + (item.attack_bonus if item else 0)
		weapon_sprite.sprite_frames = frames
	elif slot == "armor":
		armor_sprite.sprite_frames = frames
	_sync_layers()

func _apply_appearance() -> void:
	face_sprite.sprite_frames = appearance.face
	_sync_layers()

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
