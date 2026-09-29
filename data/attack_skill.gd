extends ActiveSkill
class_name AttackSkill

@export var damage_multiplier: Array[float] = [1.0]
@export var hit_height: float = 60.0 # ความสูงกล่องตี (ประชิด)
@export var projectile_scene: PackedScene # ใส่ = ยิง, ว่าง = ตีประชิด

func use(user: Node2D, level: int) -> void:
	var damage := int(user.get_attack_power() * level_value(damage_multiplier, level))
	var facing: float = user.get_facing()
	var origin: Vector2 = user.get_attack_origin()
	if projectile_scene:
		Combat.shoot(user, projectile_scene, damage, origin, facing, skill_range)
	else:
		Combat.hit_box(user, origin + Vector2(facing * skill_range / 2, 0), Vector2(skill_range, hit_height), damage)
