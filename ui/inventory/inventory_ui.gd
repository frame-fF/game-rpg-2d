extends CanvasLayer

@export var inventory: InventoryData
@onready var panel: PanelContainer = %Panel
@onready var grid: GridContainer = %Grid

func _ready() -> void:
	panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		panel.visible = not panel.visible
		if panel.visible:
			_refresh()

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	for item in inventory.items:
		var button := Button.new()
		button.text = item.item_name
		button.icon = item.icon
		button.pressed.connect(inventory.request_equip.bind(item))
		grid.add_child(button)
