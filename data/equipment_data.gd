extends Resource
class_name EquipmentData

@export var id: int
@export var item_name: String
@export var icon: Texture2D
@export_enum("weapon", "armor", "face") var slot: String = "weapon"
@export var sprite_frames: SpriteFrames

@export var max_hp_bonus: int = 0
@export var hp_bonus: int = 0

@export var defense_bonus: int = 0
@export var resistance_bonus: int = 0

@export var max_mp_bonus: int = 50
@export var mp_bonus: int = 50

@export var attack_power_bonus: int = 0
@export var attack_speed_multiplier: float = 1.0

@export var move_speed_multiplier: float = 1.0
