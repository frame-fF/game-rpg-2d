extends SkillData
class_name ActiveSkill

@export var cooldown: float = 1.0
@export var mp_cost: Array[int] = [0]
@export_enum("attack", "shoot") var animation: String = "attack"
@export var skill_range: float = 50.0 # ประชิด = ความยาวกล่องตี / ยิง = ระยะกระสุน / AI ใช้ตัดสินว่าใกล้พอไหม

func get_mp_cost(level: int) -> int:
	return level_value(mp_cost, level)

# ผู้ใช้ (ผู้เล่น/มอน) ต้องมี: team, get_attack_power(), get_facing(), get_attack_origin()
func use(_user: Node2D, _level: int) -> void:
	pass
