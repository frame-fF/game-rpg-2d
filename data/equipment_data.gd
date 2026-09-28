extends Resource
class_name EquipmentData

@export var id: int
@export var item_name: String
@export var icon: Texture2D
@export_enum("weapon", "armor", "face") var slot: String = "weapon"
@export var attack_bonus: int = 0
@export var sprite_frames: SpriteFrames
@export var attack_range: float = 0.0
@export_enum("melee", "projectile") var attack_type: String = "melee"
@export var projectile_scene: PackedScene
@export var attack_speed: float = 1.0
@export var move_speed: float = 1.0
