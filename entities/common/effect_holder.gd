extends Node
class_name EffectHolder

# Effect ที่ทำงานอยู่บนตัวละคร 1 ตัว (บัพ + Passive) — ผู้เล่นและมอนมีคนละก้อน
signal changed

var _entries: Dictionary = {} # source_id -> {name, effects, level, time_left, state, visuals}

# duration < 0 = ถาวร (Passive)
func add(source_id: String, display_name: String, effects: Array, level: int, duration: float) -> void:
	if _entries.has(source_id): # ตัวเดิมซ้ำ = ต่อเวลา ไม่ซ้อน
		_entries[source_id]["time_left"] = duration
		_entries[source_id]["level"] = level
		changed.emit()
		return
	var visuals: Array[Node2D] = []
	for effect: EffectData in effects:
		var visual := effect.make_visual(level)
		if visual:
			get_parent().add_child(visual)
			visuals.append(visual)
	_entries[source_id] = {"name": display_name, "effects": effects, "level": level,
		"time_left": duration, "state": {}, "visuals": visuals}
	changed.emit()

func remove(source_id: String) -> void:
	if not _entries.has(source_id):
		return
	for visual in _entries[source_id].visuals:
		visual.queue_free()
	_entries.erase(source_id)
	changed.emit()

func clear() -> void:
	for id in _entries.keys():
		remove(id)

func stat_flat(stat: String) -> float:
	var total := 0.0
	for entry in _entries.values():
		for effect: EffectData in entry.effects:
			total += effect.flat(stat, entry.level)
	return total

func stat_percent(stat: String) -> float:
	var total := 0.0
	for entry in _entries.values():
		for effect: EffectData in entry.effects:
			total += effect.percent(stat, entry.level)
	return total

# สำหรับ UI: [{name, time_left}, ...]
func list() -> Array:
	return _entries.values()

func _physics_process(delta: float) -> void:
	var owner_node := get_parent() as Node2D
	for id in _entries.keys():
		var entry: Dictionary = _entries[id]
		for i in entry.effects.size():
			entry.effects[i].tick(owner_node, entry.level, delta, entry.state.get_or_add(i, {}))
		if entry.time_left >= 0.0:
			entry["time_left"] -= delta
			if entry.time_left <= 0.0:
				remove(id)
