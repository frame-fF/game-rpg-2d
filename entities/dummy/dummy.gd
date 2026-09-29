extends StaticBody2D

@export var stats: StatsData

func _ready() -> void:
	stats = stats.duplicate()
	
func take_damage(amount: int, _attacker: Node2D = null) -> void:
	stats.hp -= amount
	print("Dummy took ", amount, " damage. HP: ", stats.hp, "/", stats.max_hp)
	if stats.hp <= 0:
		die()

func die() -> void:
	queue_free()
