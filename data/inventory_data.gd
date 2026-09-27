extends Resource
class_name InventoryData

signal equip_requested(item: EquipmentData)

@export var items: Array[EquipmentData] = []

func request_equip(item: EquipmentData) -> void:
	equip_requested.emit(item)
