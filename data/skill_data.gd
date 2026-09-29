extends Resource
class_name SkillData

# ไฟล์สกิลเก็บแค่ค่าที่ไม่เปลี่ยน — cooldown ที่เหลือ/เลเวล เก็บที่ตัวผู้ใช้ (SkillSetData)
@export var id: String # ใช้อ้างอิงตอน save/load ห้ามซ้ำ ห้ามเปลี่ยน
@export var skill_name: String
@export var icon: Texture2D
@export_multiline var description: String
@export var max_level: int = 1

# ค่าตามเลเวลเก็บเป็นรายการ [Lv1, Lv2, ...]
# รายการสั้นกว่าเลเวล = โตต่อด้วยส่วนต่างของ 2 ตัวท้าย เช่น [1.5, 1.6] -> Lv20 = 3.4
# ใส่ตัวเดียว = ค่าคงที่ทุกเลเวล / อยากให้บางเลเวลกระโดด = ใส่รายการเต็ม
static func pick(values: Array, level: int) -> Variant:
	assert(not values.is_empty(), "รายการค่าตามเลเวลว่าง")
	var i := maxi(level - 1, 0)
	if i < values.size():
		return values[i]
	var last: Variant = values[-1]
	var step: Variant = last - values[-2] if values.size() >= 2 else 0
	return last + step * (i - values.size() + 1)

func level_value(values: Array, level: int) -> Variant:
	return pick(values, level)
