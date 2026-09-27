extends Resource
class_name AppearanceData

@export var face: EquipmentData:
	set(value):
		face = value
		emit_changed()
