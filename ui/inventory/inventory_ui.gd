extends CanvasLayer

@export var inventory: InventoryData
@onready var panel: PanelContainer = %Panel
@onready var grid: GridContainer = %Grid

func _ready() -> void:
	panel.visible = false
	inventory.equipment_changed.connect(_on_equipment_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		panel.visible = not panel.visible
		if panel.visible:
			_refresh()

func _on_equipment_changed(_slot: String, _item: EquipmentData) -> void:
	if panel.visible:
		_refresh()

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	for item in inventory.items:
		var button := Button.new()
		button.text = item.item_name
		button.icon = item.icon
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.button_pressed = inventory.is_equipped(item)
		button.pressed.connect(inventory.toggle_equip.bind(item))
		grid.add_child(button)
