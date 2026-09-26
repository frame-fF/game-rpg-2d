extends Resource
class_name EquipmentData

@export var id: int
@export var item_name: String
@export var icon: Texture2D
@export var slot: String # "weapon" หรือ "armor"
@export var attack_bonus: int = 0
@export var sprite_frames: SpriteFrames
