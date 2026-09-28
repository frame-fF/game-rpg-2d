extends EquipmentData
class_name WeaponData

@export var attack_range: float = 0.0 # 0 = ใช้ระยะหมัด
@export_enum("melee", "projectile") var attack_type: String = "melee"
@export var projectile_scene: PackedScene
