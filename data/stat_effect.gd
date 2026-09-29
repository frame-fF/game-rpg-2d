extends EffectData
class_name StatEffect

# เพิ่ม/ลด stat — ค่าติดลบ = ลด
@export_enum("attack_power", "defense", "move_speed", "attack_speed") var stat: String = "defense"
@export_enum("add", "percent") var mode: String = "add" # add = บวกตรงๆ, percent = +x%
@export var amount: Array[float] = [10.0]

func flat(s: String, level: int) -> float:
	return SkillData.pick(amount, level) if s == stat and mode == "add" else 0.0

func percent(s: String, level: int) -> float:
	return SkillData.pick(amount, level) if s == stat and mode == "percent" else 0.0
