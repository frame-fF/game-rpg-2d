extends EffectData
class_name AuraEffect

# ทำดาเมจศัตรูรอบตัวทุก interval วินาที
@export var damage: Array[int] = [5]
@export var radius: Array[float] = [60.0]
@export var interval: float = 1.0
@export var color: Color = Color(1, 0.45, 0.1, 0.25)

func tick(owner: Node2D, level: int, delta: float, state: Dictionary) -> void:
	state["t"] = state.get("t", 0.0) + delta
	if state["t"] >= interval:
		state["t"] -= interval
		Combat.hit_circle(owner, owner.global_position, SkillData.pick(radius, level), SkillData.pick(damage, level))

func make_visual(level: int) -> Node2D:
	var circle := Polygon2D.new()
	circle.color = color
	var r: float = SkillData.pick(radius, level)
	var points := PackedVector2Array()
	for i in 24:
		points.append(Vector2.from_angle(TAU * i / 24.0) * r)
	circle.polygon = points
	circle.z_index = -1
	return circle
