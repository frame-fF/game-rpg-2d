extends ActiveSkill
class_name BuffSkill

# กดแล้วใส่ Effect ให้ตัวเองตามเวลา — กดซ้ำ = ต่อเวลา ไม่ซ้อน
@export var duration: Array[float] = [10.0]
@export var effects: Array[EffectData] = []

func use(user: Node2D, level: int) -> void:
	user.effects.add(id, skill_name, effects, level, level_value(duration, level))
