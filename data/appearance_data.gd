extends Resource
class_name AppearanceData

@export var face: SpriteFrames:
	set(value):
		face = value
		emit_changed()
