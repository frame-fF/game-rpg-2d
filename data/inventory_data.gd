extends Resource
class_name InventoryData

signal equipment_changed(slot: String, item: EquipmentData)

@export var items: Array[EquipmentData] = []
var equipped: Dictionary = {}

func toggle_equip(item: EquipmentData) -> void:
	if is_equipped(item):
		equipped.erase(item.slot)
		equipment_changed.emit(item.slot, null)
	else:
		equipped[item.slot] = item
		equipment_changed.emit(item.slot, item)

func is_equipped(item: EquipmentData) -> bool:
	return equipped.get(item.slot) == item

func get_attack_bonus() -> int:
	var total := 0
	for item in equipped.values():
		total += item.attack_bonus
	return total
