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
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: StatsData
@onready var attack_area: Area2D = $AttackArea
@onready var armor_sprite: AnimatedSprite2D = $ArmorSprite
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var face_sprite: AnimatedSprite2D = $FaceSprite
@export var appearance: AppearanceData

@export var inventory: InventoryData

func _ready() -> void:
	inventory.equipment_changed.connect(_on_equipment_changed)
	animated_sprite.frame_changed.connect(_sync_layers)
	animated_sprite.animation_changed.connect(_sync_layers)
	appearance.changed.connect(_apply_appearance)
	_apply_appearance()
	attack_shape.shape = attack_shape.shape.duplicate()
	_set_attack_range(unarmed_range)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= _delta

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
		animated_sprite.play("attack", stats.attack_speed * inventory.get_attack_speed())
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk", move_speed / WALK_ANIM_SPEED)
	else:
		animated_sprite.play("idle")


func _attack() -> void:
	var damage := stats.attack_power + inventory.get_attack_bonus()
	var weapon := inventory.equipped.get("weapon") as WeaponData
	if weapon and weapon.attack_type == "projectile":
		_shoot(weapon.projectile_scene, damage)
		return
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)



func _on_equipment_changed(slot: String, item: EquipmentData) -> void:
	var frames: SpriteFrames = item.sprite_frames if item else null
	if slot == "weapon":
		weapon_sprite.sprite_frames = frames
		var weapon := item as WeaponData
		_set_attack_range(weapon.attack_range if weapon and weapon.attack_range > 0 else unarmed_range)

	elif slot == "armor":
		armor_sprite.sprite_frames = frames
	_sync_layers()

func _apply_appearance() -> void:
	face_sprite.sprite_frames = appearance.face.sprite_frames if appearance.face else null
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

func _set_attack_range(value: float) -> void:
	attack_range = value
	attack_shape.shape.size.x = value

func _shoot(scene: PackedScene, damage: int) -> void:
	var projectile := scene.instantiate() as Projectile
	projectile.direction = facing_direction
	projectile.damage = damage
	projectile.shooter = self
	projectile.position = position + Vector2(ATTACK_START * facing_direction, -10)
	get_parent().add_child(projectile)

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
