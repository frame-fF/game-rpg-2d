extends Resource
class_name EquipmentData

@export var id: int
@export var item_name: String
@export var icon: Texture2D
@export_enum("weapon", "armor", "face") var slot: String = "weapon"
@export var sprite_frames_male: SpriteFrames
@export var sprite_frames_female: SpriteFrames # ว่างไว้ = ใช้ของ male แทน
@export_enum("any", "male", "female") var gender_lock: String = "any"

@export var max_hp_bonus: int = 0
@export var hp_bonus: int = 0

@export var defense_bonus: int = 0
@export var resistance_bonus: int = 0

@export var max_mp_bonus: int = 0
@export var mp_bonus: int = 0

@export var attack_power_bonus: int = 0
@export var attack_speed_multiplier: float = 1.0

@export var move_speed_multiplier: float = 1.0

func get_frames(gender: String) -> SpriteFrames:
	if gender == "female" and sprite_frames_female:
		return sprite_frames_female
	return sprite_frames_male

func can_equip(gender: String) -> bool:
	return gender_lock == "any" or gender_lock == gender
