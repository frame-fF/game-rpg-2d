extends Resource
class_name EffectData

# ชิ้นส่วน "ผลที่ติดตัว" ใส่ในบัพ/Passive ได้หลายชิ้น — ไฟล์นี้เก็บแค่ค่าคงที่
# ค่าตอนเล่น (ตัวจับเวลา ฯลฯ) อยู่ใน state ที่ EffectHolder ส่งมาให้

func flat(_stat: String, _level: int) -> float:
	return 0.0

func percent(_stat: String, _level: int) -> float:
	return 0.0

func tick(_owner: Node2D, _level: int, _delta: float, _state: Dictionary) -> void:
	pass

func make_visual(_level: int) -> Node2D:
	return null
