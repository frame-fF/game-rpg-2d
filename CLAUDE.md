# CLAUDE.md

## Skill ที่ต้องใช้เสมอ
สำหรับงาน Godot ทุกครั้ง (ออกแบบสถาปัตยกรรม, เขียน GDScript, debug, สร้างระบบ node/scene, migrate เวอร์ชัน ฯลฯ) ให้เรียกใช้ skill **godot-master** ก่อนเสมอ
(ที่มา: https://github.com/thedivergentai/gd-agentic-skills)

**เรียกใหม่ทุกครั้งที่เริ่มงานชิ้นใหม่** (ไม่ใช่เรียกครั้งเดียวแล้วใช้ต่อทั้งบทสนทนา) และนอกจาก godot-master ให้เรียก **skill godot อื่นทุกตัวที่ตรงกับงานนั้น** ด้วย + เปิดไฟล์อ้างอิงใน godot-master ที่ตรงเรื่อง (เช่น Combat, RPG Stats, Ability System, Inventory, Save/Load):

| งาน | skill ที่ต้องเรียกเพิ่ม |
|---|---|
| เขียน/แก้ GDScript ทุกชนิด | `godot-gdscript`, `godot-gdscript-patterns` |
| ข้อมูลเป็น Resource / `.tres` (stats, ไอเทม, สกิล, effect) | `godot-resources` |
| signal, group, การสื่อสารระหว่าง node | `godot-signals-groups` |
| สร้าง/จัด node, scene, Inherited Scene | `godot-nodes-scenes` |
| collision layer/mask, Area2D, physics query | `godot-physics` |
| การเคลื่อนที่ตัวละคร/มอน (CharacterBody2D) | `godot-2d-movement` |
| AnimatedSprite2D, SpriteFrames, ท่าทาง | `godot-animation` |
| UI (HUD, กระเป๋า, ช่องสกิล, เมนู) | `godot-ui-control` |
| แผนที่ด้วย tile | `godot-tilemap` |
| เสียง | `godot-audio` |
| shader / เอฟเฟกต์ภาพ | `godot-shaders` |
| ออนไลน์ / multiplayer | `godot-multiplayer` |
| export / ปล่อยเกม | `godot-export` |
| อัปเกรดเวอร์ชัน Godot | `godot-4-migration` |

skill เกมทั่วไปที่ใช้ร่วมได้เมื่อตรงเรื่อง: `rpg`, `platformer`, `game-ai`, `game-feel`, `level-design`, `save-systems`, `input-systems`, `camera-systems`
(ไม่ใช้: `godot-csharp` — เกมนี้ใช้ GDScript, `godot-3d-essentials` — เกม 2D)

## เอกสารอ้างอิงหลัก
เวลาไม่มั่นใจเรื่อง API/property/signal ชื่อจริง (เช่น ชื่อ Color constant, property ของ node, signature ของ built-in function) ให้เช็คกับ Godot 4.7 official docs ก่อนเดา:
- https://docs.godotengine.org/en/stable/
ห้ามเดาชื่อ constant/property ที่ไม่ชัวร์แล้วปล่อยผ่าน — เคยทำให้ script error มาแล้ว (เดาใช้ `Color.SKY_BLUE` ที่ไม่มีจริงใน Godot)

## ข้อควรระวังเวลาทำงานกับ Godot + godot-ai (ใช้ได้ทุกโปรเจกต์)
- **ห้ามใส่ `uid=` ซ้ำของสคริปต์เก่าที่ลบไปแล้วให้ `ext_resource` ในไฟล์ .tscn** — Godot cache uid ไว้ ถ้า path เก่าถูกลบแต่ uid ซ้ำ จะโหลดสคริปต์ไม่ขึ้นแบบเงียบๆ (ไม่มี error ชัดเจนจนกว่าจะรันจริง) ถ้าจะเปลี่ยนชื่อ/ย้ายสคริปต์ ให้ไม่ต้องใส่ `uid=` เลย ปล่อยให้ Godot สร้างใหม่
- **ทุกครั้งที่แก้ .tscn หรือ .gd เสร็จ ให้ทดสอบผ่าน `godot-ai` MCP ก่อนบอกว่าเสร็จ**: `scene_open(force_reload=true)` เช็ค `new_errors_since_last_call`, แล้ว `project_run` ดู `current_run_errors`/`recent_errors` ก่อนสรุปผลให้ผู้ใช้
- การจำลองคลิกเมาส์/พิมพ์คีย์บอร์ดผ่าน `game_manage` (input_mouse/input_key) ไม่เสถียร — ให้ยืนยันผลจริงด้วย `get_node_info` เช็คค่า property (เช่น `.text`) แทนที่จะดูแค่ screenshot
