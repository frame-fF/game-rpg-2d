extends CanvasLayer

@export var stats: StatsData
@onready var hp_bar: ProgressBar = $HpBar
@onready var mp_bar: ProgressBar = $MpBar

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
