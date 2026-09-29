extends ActiveSkill
class_name SummonSkill

# เสกมอนข้างตัว — ลูกน้องอยู่ฝ่ายเดียวกับคนเสก และไล่เป้าเดียวกัน
@export var monster_scene: PackedScene
@export var count: Array[int] = [1]     # เสกทีละกี่ตัว
@export var max_alive: Array[int] = [3] # มีลูกน้องที่ยังไม่ตายได้สูงสุดกี่ตัว
@export var spread: float = 40.0        # ระยะห่างระหว่างตัวที่เสก
@export var lifetime: Array[float] = [0.0] # อยู่ได้กี่วินาที, 0 = อยู่จนตาย

func use(user: Node2D, level: int) -> void:
	var group := "summons_%d" % user.get_instance_id() # ลูกน้องของคนเสกคนนี้
	var alive := user.get_tree().get_nodes_in_group(group).size()
	var amount := mini(level_value(count, level), level_value(max_alive, level) - alive)
	for i in amount:
		var minion := monster_scene.instantiate() as Node2D
		minion.position = user.position + Vector2(user.get_facing() * spread * (i + 1), -10)
		minion.add_to_group(group)
		user.get_parent().add_child(minion)
		minion.team = user.team
		minion.leader = user
		minion.lifetime = level_value(lifetime, level)
		if user.get("target"):
			minion.target = user.target
