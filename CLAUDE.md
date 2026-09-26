# CLAUDE.md

## Skill ที่ต้องใช้เสมอ
สำหรับงาน Godot ทุกครั้ง (ออกแบบสถาปัตยกรรม, เขียน GDScript, debug, สร้างระบบ node/scene, migrate เวอร์ชัน ฯลฯ) ให้เรียกใช้ skill **godot-master** ก่อนเสมอ
(ที่มา: https://github.com/thedivergentai/gd-agentic-skills)

## เอกสารอ้างอิงหลัก
เวลาไม่มั่นใจเรื่อง API/property/signal ชื่อจริง (เช่น ชื่อ Color constant, property ของ node, signature ของ built-in function) ให้เช็คกับ Godot 4.7 official docs ก่อนเดา:
- https://docs.godotengine.org/en/stable/
ห้ามเดาชื่อ constant/property ที่ไม่ชัวร์แล้วปล่อยผ่าน — เคยทำให้ script error มาแล้ว (เดาใช้ `Color.SKY_BLUE` ที่ไม่มีจริงใน Godot)

## ข้อควรระวังเวลาทำงานกับ Godot + godot-ai (ใช้ได้ทุกโปรเจกต์)
- **ห้ามใส่ `uid=` ซ้ำของสคริปต์เก่าที่ลบไปแล้วให้ `ext_resource` ในไฟล์ .tscn** — Godot cache uid ไว้ ถ้า path เก่าถูกลบแต่ uid ซ้ำ จะโหลดสคริปต์ไม่ขึ้นแบบเงียบๆ (ไม่มี error ชัดเจนจนกว่าจะรันจริง) ถ้าจะเปลี่ยนชื่อ/ย้ายสคริปต์ ให้ไม่ต้องใส่ `uid=` เลย ปล่อยให้ Godot สร้างใหม่
- **ทุกครั้งที่แก้ .tscn หรือ .gd เสร็จ ให้ทดสอบผ่าน `godot-ai` MCP ก่อนบอกว่าเสร็จ**: `scene_open(force_reload=true)` เช็ค `new_errors_since_last_call`, แล้ว `project_run` ดู `current_run_errors`/`recent_errors` ก่อนสรุปผลให้ผู้ใช้
- การจำลองคลิกเมาส์/พิมพ์คีย์บอร์ดผ่าน `game_manage` (input_mouse/input_key) ไม่เสถียร — ให้ยืนยันผลจริงด้วย `get_node_info` เช็คค่า property (เช่น `.text`) แทนที่จะดูแค่ screenshot
