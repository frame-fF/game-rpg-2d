extends Resource
class_name SkillSetData

# สกิลของตัวละคร 1 ตัว: ช่อง 1-4 + เลเวลที่เรียน + cooldown ที่เหลือ
@export var hotbar: Array[ActiveSkill] = [null, null, null, null]
@export var levels: Dictionary = {} # id สกิล -> เลเวล (ไม่มี = Lv1)
var cooldowns: Dictionary = {}      # id สกิล -> วินาทีที่เหลือ (ค่าตอนเล่น ไม่เซฟ)

func get_level(skill: SkillData) -> int:
	return levels.get(skill.id, 1)

func is_ready(skill: ActiveSkill) -> bool:
	return cooldowns.get(skill.id, 0.0) <= 0.0

func start_cooldown(skill: ActiveSkill) -> void:
	cooldowns[skill.id] = skill.cooldown

func tick(delta: float) -> void:
	for id in cooldowns:
		cooldowns[id] = maxf(cooldowns[id] - delta, 0.0)
