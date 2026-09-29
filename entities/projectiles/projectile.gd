extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var max_distance: float = 300.0
var direction: float = 1.0
var damage: int = 0
var shooter: Node
var team: Variant # ฝ่ายของคนยิง — ไม่โดนฝ่ายเดียวกัน
var _traveled: float = 0.0

func _ready() -> void:
	scale.x = direction
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var step := speed * delta
	position.x += step * direction
	_traveled += step
	if _traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == shooter or (team != null and body.get("team") == team):
		return # ทะลุฝ่ายเดียวกัน
	if body.has_method("take_damage"):
		body.take_damage(damage, shooter if is_instance_valid(shooter) else null)
	queue_free()
