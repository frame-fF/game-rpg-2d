class_name Combat

# โค้ดตีกลาง: ผู้เล่น มอน สกิล กระสุน ตีกันผ่านที่นี่ที่เดียว
const HIT_MASK := 1 | 2 | 4 # world + player + monster (กรองฝ่ายด้วย team แทน)

# คนละฝ่าย = ตีได้ (ของที่ไม่มี team เช่น Dummy ถือเป็นศัตรูของทุกฝ่าย)
static func is_enemy(attacker: Node, body: Node) -> bool:
	return body != attacker and body.has_method("take_damage") \
		and (attacker == null or body.get("team") != attacker.get("team"))

static func hit_bodies(attacker: Node2D, bodies: Array, damage: int) -> int:
	var hits := 0
	for body in bodies:
		if is_enemy(attacker, body):
			body.take_damage(damage, attacker)
			hits += 1
	return hits

static func hit_box(attacker: Node2D, center: Vector2, size: Vector2, damage: int) -> int:
	var shape := RectangleShape2D.new()
	shape.size = size
	return _hit_shape(attacker, shape, center, damage)

static func hit_circle(attacker: Node2D, center: Vector2, radius: float, damage: int) -> int:
	var shape := CircleShape2D.new()
	shape.radius = radius
	return _hit_shape(attacker, shape, center, damage)

static func _hit_shape(attacker: Node2D, shape: Shape2D, center: Vector2, damage: int) -> int:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, center)
	query.collision_mask = HIT_MASK
	var bodies := []
	for result in attacker.get_world_2d().direct_space_state.intersect_shape(query, 32):
		bodies.append(result.collider)
	return hit_bodies(attacker, bodies, damage)

static func shoot(attacker: Node2D, scene: PackedScene, damage: int, origin: Vector2, facing: float, max_distance: float = 0.0) -> void:
	var projectile := scene.instantiate() as Projectile
	projectile.direction = facing
	projectile.damage = damage
	projectile.shooter = attacker
	projectile.team = attacker.get("team")
	if max_distance > 0.0:
		projectile.max_distance = max_distance
	projectile.position = origin
	attacker.get_parent().add_child(projectile)
