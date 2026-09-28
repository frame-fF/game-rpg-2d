extends Resource
class_name AppearanceData

@export_enum("male", "female") var gender: String = "male":
	set(value):
		gender = value
		emit_changed()

@export var face: EquipmentData:
	set(value):
		face = value
		emit_changed()
