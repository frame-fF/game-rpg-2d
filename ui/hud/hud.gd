extends CanvasLayer

@export var stats: StatsData
@onready var hp_bar: ProgressBar = $HpBar

func _ready() -> void:
	if stats == null:
		return
	stats.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
