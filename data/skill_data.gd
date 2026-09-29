extends Resource
class_name SkillData

# ไฟล์สกิลเก็บแค่ค่าที่ไม่เปลี่ยน — cooldown ที่เหลือ/เลเวล เก็บที่ตัวผู้ใช้ (SkillSetData)
@export var id: String # ใช้อ้างอิงตอน save/load ห้ามซ้ำ ห้ามเปลี่ยน
@export var skill_name: String
@export var icon: Texture2D
@export_multiline var description: String
@export var max_level: int = 1

# ค่าตามเลเวลเก็บเป็นรายการ [Lv1, Lv2, ...] ถ้ารายการสั้นกว่าเลเวล ใช้ตัวสุดท้าย
func level_value(values: Array, level: int) -> Variant:
	assert(not values.is_empty(), "%s: รายการค่าตามเลเวลว่าง" % id)
	return values[clampi(level - 1, 0, values.size() - 1)]
