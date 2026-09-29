extends Resource
class_name InventoryData

signal equipment_changed(slot: String, item: EquipmentData)

@export var items: Array[EquipmentData] = []
var equipped: Dictionary = {}

func toggle_equip(item: EquipmentData, gender: String) -> void:
	if is_equipped(item):
		equipped.erase(item.slot)
		equipment_changed.emit(item.slot, null)
	elif item.can_equip(gender):
		equipped[item.slot] = item
		equipment_changed.emit(item.slot, item)

func is_equipped(item: EquipmentData) -> bool:
	return equipped.get(item.slot) == item

func unequip_locked(gender: String) -> void:
	for item in equipped.values():
		if not item.can_equip(gender):
			toggle_equip(item, gender)

func get_attack_power_bonus() -> int:
	var total := 0
	for item in equipped.values():
		total += item.attack_power_bonus
	return total
	
func get_defense_bonus() -> int:
	var total := 0
	for item in equipped.values():
		total += item.defense_bonus
	return total

func get_attack_speed() -> float:
	var total := 1.0
	for item in equipped.values():
		total *= item.attack_speed_multiplier
	return total

func get_move_speed() -> float:
	var total := 1.0
	for item in equipped.values():
		total *= item.move_speed_multiplier
	return total

# ใช้ใน get_stat() ของผู้เล่น: ชุดบวกตรงๆ / ชุดคูณ
func get_flat_bonus(stat: String) -> float:
	match stat:
		"attack_power": return get_attack_power_bonus()
		"defense": return get_defense_bonus()
	return 0.0

func get_multiplier(stat: String) -> float:
	match stat:
		"attack_speed": return get_attack_speed()
		"move_speed": return get_move_speed()
	return 1.0
