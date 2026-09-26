# แผนพัฒนาเกม RPG Online 2D (แบบ Ghost Online / MapleStory)

## Phase 0 — Scope ให้เล็กที่สุด (อย่าข้าม)
เกมแนวนี้ fail ส่วนใหญ่เพราะ scope ใหญ่เกินตัวคนเดียว/ทีมเล็ก ตัดสินใจตั้งแต่ต้น:
- คลาสตัวละครแรก: **1 คลาสพอ** (เพิ่มทีหลังง่ายกว่าที่คิด)
- แมพแรก: **1 โซนเล็กๆ** (village + dungeon เดียว)
- ระบบต่อสู้: เลือกแบบเดียว (real-time action หรือ turn-based) อย่าทำทั้งคู่

## Phase 1 — Single-player core loop (ทำก่อน network ทั้งหมด)
ลำดับที่แนะนำ:
1. Movement + collision (2D platformer/topdown physics)
2. ระบบ Stats (HP/MP/EXP/Level) — data-driven ด้วย `Resource`
3. ระบบต่อสู้พื้นฐาน (attack, damage formula, death) — ดูตัวอย่างสูตรใน [อ้างอิง: Damage Formula](#อ้างอิง-damage-formula) ท้ายไฟล์
4. Inventory + Item pickup/ใช้ไอเทม
5. Skill system (cooldown, mana cost, effect)
6. Save/Load ตัวละคร (local ก่อน ยังไม่ต้องมี server)

ทำจนเล่นคนเดียวได้ครบ loop จริง ๆ ก่อนแตะ network เลย

## Phase 2 — Data architecture (วางไว้ตั้งแต่ Phase 1 จะได้ไม่ต้อง refactor)

**Design-time data (ไม่เปลี่ยนตอน runtime)** → ใช้ Godot custom `Resource`:

```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var id: int
@export var name: String
@export var icon: Texture2D
@export var stack_max: int = 99
@export var type: String # "weapon", "consumable", "material"
```

ทำแบบเดียวกันกับ `SkillData`, `MonsterData`, `ClassData` — สร้างเป็นไฟล์ `.tres` แต่ละอัน แก้ค่าผ่าน Inspector ได้เลย ไม่ต้องแตะโค้ด

**Player/runtime data (เปลี่ยนตลอดเวลา)**:
- ตอน prototype (single-player): เก็บเป็น JSON local file พอ
- พอเข้า Phase 4 (online): **ต้องย้ายไป server-side DB** (SQLite ตอนเทส → PostgreSQL ตอนจริง) เพราะ:
  - client ส่งค่ามาแก้เองไม่ได้ (กันโกง exp/item/เงิน)
  - ต้อง sync ข้าม session/เครื่อง

โครงสร้างตารางคร่าวๆ:

```
players(id, username, level, exp, hp, mp, x, y, map_id)
inventory(player_id, item_id, quantity, slot)
player_skills(player_id, skill_id, skill_level)
```

## Phase 3 — Server authority (สำคัญที่สุดสำหรับ online RPG)
- **Client ไม่คำนวณผลลัพธ์ที่มีผลถาวร** (damage, drop, exp) — client แค่ "ขอทำ action" server ตัดสิน แล้วส่งผลกลับ
- Godot มี `MultiplayerAPI`/`ENetMultiplayerPeer` ในตัว พอสำหรับ dungeon/party (ผู้เล่นไม่กี่สิบคนต่อ instance)
- ถ้าจะทำโลกเปิดคนเยอะจริง (หลักร้อย/พันต่อแมพพร้อมกันแบบ MapleStory) built-in multiplayer ของ Godot ไม่พอ ต้องแยก **game server เขียนเอง** (Node.js/Go/C#) แล้วให้ Godot client ต่อผ่าน WebSocket/TCP — นี่คือจุดที่ Godot ทำหน้าที่แค่ renderer/client เท่านั้น

## Phase 4 — Network model ที่ต้องเลือก

| แบบ | เหมาะกับ | Godot รองรับ |
|---|---|---|
| P2P/host-client (ENet built-in) | party dungeon, coop เล็ก | รองรับตรง ๆ |
| Dedicated game server + DB | โลกเปิด, MMO จริง | ต้องเขียน server แยก, Godot เป็น client |

ให้เดาจากที่ต้องการ (Maple/Ghost Online): เป็นแบบหลัง — วางแผน server แยกจาก client ตั้งแต่ต้น อย่าคิดว่า built-in multiplayer ของ Godot จะ scale ไปถึงตรงนั้น

## สรุปลำดับทำจริง
1. Core gameplay single-player (Resource-based item/skill/stat)
2. Local save/load
3. ทำ dungeon/party แบบ ENet (Godot native) ทดสอบ concept multiplayer เล็ก
4. ถ้าจะไปต่อเป็น MMO จริง → เขียน backend server แยก + DB, Godot client ต่อผ่าน network

## อ้างอิง: Damage Formula
- [A Guide to Damage Formulas | RPG Maker Forums](https://forums.rpgmakerweb.com/threads/a-guide-to-damage-formulas.145148/)
- [Damage Formula | RPG | Fandom](https://rpg.fandom.com/wiki/Damage_Formula)
- [RPG Damage Formula Calculator | CalcBee](https://calcbee.com/calculators/gaming/rpg/rpg-damage-formula/)
- [RPG Combat Simulator](https://leashagamesdev.itch.io/rpg-maker-mz-damage-formula-simulator)
- [What to consider for an RPG damage formula? - GameDev.net](https://gamedev.net/forums/topic/681632-what-to-consider-for-an-rpg-damage-formula/5307753/)
