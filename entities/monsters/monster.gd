extends CharacterBody2D

const ATTACK_HIT_FRAME := 1 # เฟรมที่ลิ้นยื่นสุด = จังหวะโดน
const ATTACK_BOX_X := 42.0  # จุดกลางกล่องโจมตี (ลิ้นยื่น 10-74 px หน้าตัว)

@export var stats: StatsData
@export var patrol_distance: float = 100.0
@export var attack_range: float = 70.0
@export var attack_cooldown: float = 1.5

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 1.0
var start_x: float
var target: Node2D
var is_attacking: bool = false
var cooldown_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	stats = stats.duplicate()
	start_x = position.x
	detect_area.body_entered.connect(_on_detect_entered)
	detect_area.body_exited.connect(_on_detect_exited)
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

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
	attack_area.position.x = ATTACK_BOX_X * direction
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
	if sprite.animation != "attack" or sprite.frame != ATTACK_HIT_FRAME:
		return
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(stats.attack_power)

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false

func _on_detect_entered(body: Node2D) -> void:
	target = body

func _on_detect_exited(body: Node2D) -> void:
	if body == target:
		target = null

func take_damage(amount: int) -> void:
	stats.hp -= amount
	print("Monster took ", amount, " damage. HP: ", stats.hp, "/", stats.max_hp)
	if stats.hp <= 0:
		queue_free()
