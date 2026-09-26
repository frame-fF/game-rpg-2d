extends CharacterBody2D

@export var speed: float = 200.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	if direction != Vector2.ZERO:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.play("idle")
