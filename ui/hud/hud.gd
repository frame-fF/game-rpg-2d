extends CanvasLayer

@export var stats: StatsData
@onready var hp_bar: ProgressBar = $HpBar
@onready var mp_bar: ProgressBar = $MpBar
@onready var buff_label: Label = $BuffLabel
@export var effects_owner: Node # ตัวละครที่จะแสดงบัพ (ต้องมี .effects)

func _ready() -> void:
	if stats == null:
		return
	stats.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
	mp_bar.max_value = stats.max_mp
	mp_bar.value = stats.mp

func _process(_delta: float) -> void:
	if effects_owner == null or effects_owner.effects == null:
		return
	var parts: PackedStringArray = []
	for entry in effects_owner.effects.list():
		parts.append(entry.name if entry.time_left < 0.0 else "%s %ds" % [entry.name, ceili(entry.time_left)])
	buff_label.text = "  |  ".join(parts)
