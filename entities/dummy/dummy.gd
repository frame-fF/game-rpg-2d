extends StaticBody2D

@export var stats: StatsData

func take_damage(amount: int) -> void:
	stats.hp -= amount
	print("Dummy took ", amount, " damage. HP: ", stats.hp, "/", stats.max_hp)
	if stats.hp <= 0:
		die()

func die() -> void:
	queue_free()
