extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.6
var facing_direction: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: StatsData

func _ready() -> void:
	pass

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

	if is_dashing:
		velocity.x = facing_direction * dash_speed
		dash_timer -= _delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity.x = direction * speed

	move_and_slide()

	animated_sprite.flip_h = facing_direction < 0

	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
