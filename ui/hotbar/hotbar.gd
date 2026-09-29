extends CanvasLayer

# ช่องสกิล 1-4 ล่างจอ: แสดงไอคอน/ชื่อสกิล + cooldown ที่เหลือ (อ่านจาก SkillSetData อย่างเดียว ไม่แก้ข้อมูล)
const SLOT_SIZE := Vector2(56, 56)

@export var skills: SkillSetData

var _slots: Array[Dictionary] = [] # {icon, name, cooldown}

func _ready() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	for i in 4:
		row.add_child(_make_slot(i))
	add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 12)
	row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_refresh()

func _process(_delta: float) -> void:
	for i in _slots.size():
		var skill := _skill_at(i)
		var left: float = skills.cooldowns.get(skill.id, 0.0) if skill else 0.0
		_slots[i].cooldown.text = "%.1f" % left if left > 0.0 else ""

func _refresh() -> void:
	for i in _slots.size():
		var skill := _skill_at(i)
		_slots[i].icon.texture = skill.icon if skill else null
		_slots[i].name.text = skill.skill_name if skill and not skill.icon else ""

func _skill_at(i: int) -> ActiveSkill:
	return skills.hotbar[i] if skills and i < skills.hotbar.size() else null

func _make_slot(i: int) -> Control:
	var panel := Panel.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := TextureRect.new()
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 4)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(icon)
	var name_label := _label(panel, Control.PRESET_CENTER, 11)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.size = SLOT_SIZE
	name_label.position = Vector2.ZERO
	var key_label := _label(panel, Control.PRESET_TOP_LEFT, 12)
	key_label.text = str(i + 1)
	key_label.position = Vector2(4, 2)
	var cooldown := _label(panel, Control.PRESET_FULL_RECT, 18)
	cooldown.modulate = Color(1, 0.85, 0.3)
	_slots.append({"icon": icon, "name": name_label, "cooldown": cooldown})
	return panel

func _label(parent: Control, preset: Control.LayoutPreset, font_size: int) -> Label:
	var label := Label.new()
	label.set_anchors_and_offsets_preset(preset)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label
