# บันทึกการเรียนรู้ Godot — จากศูนย์สู่ตัวละครที่เดิน/กระโดด/พุ่งได้

เอกสารนี้สรุปทุกขั้นตอนที่ทำมาตั้งแต่เริ่มโปรเจกต์ พร้อมคำอธิบายแนวคิด Godot ที่เจอระหว่างทาง และปัญหา/บั๊กที่เจอจริงพร้อมวิธีแก้ ใช้เป็นบทเรียนอ้างอิงสำหรับโปรเจกต์ Godot ในอนาคตได้

---

## 1. แนวคิดพื้นฐานของ Godot

| คำศัพท์ | ความหมาย |
|---|---|
| **Scene** (`.tscn`) | หน่วยหนึ่งของเกม เช่น ตัวละคร, ด่าน, เมนู — เทียบเท่า "prefab" ที่เอาไปใช้ซ้ำได้ |
| **Node** | ชิ้นส่วนในฉาก (รูปภาพ, กล่องชนกัน, กล้อง ฯลฯ) เอามาต่อกันเป็น Scene |
| **Script** (`.gd`) | โค้ดที่ติดกับ Node สั่งให้มันทำงาน — สคริปต์ "extends" ชนิด node นั้นๆ |
| **Resource** (`.tres`) | ไฟล์เก็บ "ข้อมูล" ล้วนๆ (ไม่มีพฤติกรรม) เช่น Stats, Item — แก้ผ่าน Inspector ได้โดยไม่แตะโค้ด |
| **Instancing** | เอา scene หนึ่งไปวางเป็นส่วนหนึ่งของอีก scene (เช่น เอา `player.tscn` ไปวางใน `village.tscn`) |

### Built-in virtual function (ชื่อฟังก์ชันห้ามเปลี่ยน)
ฟังก์ชันขึ้นต้นด้วย `_` เช่น `_ready()`, `_process(delta)`, `_physics_process(delta)` เป็นชื่อที่ Godot กำหนดตายตัว engine จะเรียกให้เองอัตโนมัติตามจังหวะ ไม่ใช่ชื่อที่ตั้งเอง

**วิธีหาว่ามีฟังก์ชัน built-in อะไรบ้าง:**
1. พิมพ์ `func _` ในสคริปต์แล้วรอ autocomplete
2. กด **F1** หรือ Help → Search Help พิมพ์ชื่อ node เพื่อดู class reference ในเอดิเตอร์
3. เว็บ [Godot Official Docs](https://docs.godotengine.org/en/stable/)

**ทำไมต้องใช้ `_physics_process` แทน `_process` สำหรับการเคลื่อนที่:**
`_physics_process` รันด้วยจังหวะเวลาคงที่เสมอ (ปกติ 60 ครั้ง/วินาที) ต่างจาก `_process` ที่ขึ้นกับ FPS จอ — การเดิน/ชนกำแพงต้องใช้จังหวะคงที่ ไม่งั้นจะกระตุกเวลา FPS ขึ้นๆ ลงๆ

---

## 2. Node ชนิดต่างๆ ที่ใช้ และหน้าที่

| Node | ใช้ทำอะไร |
|---|---|
| **CharacterBody2D** | ตัวละครที่ควบคุมการเดินเอง ชนกำแพงแล้วหยุด/สไลด์ (ต่างจาก RigidBody2D ที่ปล่อยให้ฟิสิกส์คำนวณเอง, StaticBody2D ที่อยู่นิ่งตลอด) |
| **StaticBody2D** | ของที่อยู่นิ่งตลอด ไม่ขยับ เหมาะกับกำแพง/พื้น |
| **CollisionShape2D** | กำหนด "ขอบเขตชน" ให้ physics body — ต้องมี **Shape** (เช่น RectangleShape2D) ไม่งั้น node เปล่าไม่ทำอะไร |
| **Sprite2D** | แสดงรูปภาพนิ่งรูปเดียว |
| **AnimatedSprite2D** | แสดงภาพเคลื่อนไหวหลายเฟรม ต้องมี **SpriteFrames** resource เก็บกลุ่มเฟรมแยกเป็นแต่ละ animation |
| **Polygon2D** | วาดรูปทรงหลายเหลี่ยมเติมสีทึบ (ใช้แทนกำแพง/พื้นชั่วคราวก่อนมีรูปจริง) — เป็น Node2D ใช้ Position ตรงๆ |
| **ColorRect** | สี่เหลี่ยมสีทึบเหมือนกัน แต่เป็น **Control** (UI) ใช้ระบบ Anchor/Layout ซับซ้อนกว่า **ไม่เหมาะกับฉากโลกเกม 2D** ควรใช้ Polygon2D/Sprite2D แทน |
| **Camera2D** | กล้องที่ต้องมีในทุกเกม ไม่งั้น world origin (0,0) จะไปอยู่มุมบนซ้ายจอแทนกึ่งกลาง ทำให้มองไม่เห็นอะไรเลยถ้าตัวละครอยู่พิกัดติดลบ |

### ตารางเทียบ Node vs RefCounted vs Resource vs Object
ใช้ `Resource` สำหรับข้อมูลที่ต้องแก้ผ่าน Inspector (เช่น Stats, Item), ใช้ `Node` เฉพาะของที่ต้องมีอยู่ใน scene tree จริงๆ (ต้องการ `_process`/ตำแหน่งในโลก)

---

## 3. ลำดับขั้นตอนที่ทำมาจริง

### 3.1 โครงสร้างโปรเจกต์ (Feature-based)
จัดกลุ่มไฟล์ตาม "ฟีเจอร์" ไม่ใช่ตาม "ชนิดไฟล์" (ห้ามมีโฟลเดอร์ `/scripts`, `/sprites` แยกต่างหาก):
```
data/                          ← สคริปต์แม่แบบ Resource (class_name) ใช้ร่วมกันทั้งเกม
├── stats_data.gd
├── equipment_data.gd          ← แม่ของไอเทมทุกชนิด
├── weapon_data.gd, armor_data.gd  ← ลูก (extends EquipmentData)
├── appearance_data.gd
└── inventory_data.gd
items/                         ← ข้อมูลไอเทมจริง (.tres) = ตัวไอเทม + SpriteFrames แยกเพศ
├── armor/   armor_1_m.tres (ล็อก male), armor_1_f.tres (ล็อก female), armor_1_frames_m/f.tres
├── weapons/
│   ├── sword/1/  1.tres, 1_frames_m.tres, 1_frames_f.tres
│   └── bow/1/    1.tres, 1_frames_m.tres, 1_frames_f.tres
└── face/    face_1.tres, face_1_frames_m.tres, face_1_frames_f.tres
entities/player/
├── player.tscn, player.gd
├── player_stats.tres, player_inventory.tres, player_appearance.tres
├── body_frames_m.tres, body_frames_f.tres   ← SpriteFrames ตัวละครแยกเพศ
└── sprites/
    ├── base_body/m/, base_body/f/   ← เฟรมตัว (idle_0, walk_3, ...)
    ├── armor/1/               ← icon.png + m/ + f/ (เฟรมแต่ละเพศ)
    ├── weapons/sword/1/, weapons/bow/1/  ← icon.png + m/ + f/
    └── face/1/                ← icon.png + m/ + f/
entities/monsters/
├── monster.gd, monster.tscn   ← โค้ด/ฉากกลาง ใช้ทุกมอน
├── 1/  sprites/, frames.tres, stats.tres               ← มอนตีประชิด (ลิ้น)
└── 2/  sprites/, frames.tres, stats.tres, monster_2.tscn (Inherited)  ← มอนตีไกล (ผี)
entities/dummy/                ← dummy.tscn, dummy.gd, dummy_stats.tres (แม่แบบ)
entities/projectiles/          ← projectile.gd, arrow.tscn (ผู้เล่น), enemy_orb.tscn (มอน)
ui/hud/, ui/inventory/
levels/village.tscn            ← ด่านทดสอบ
```
นอกโปรเจกต์: `Desktop\assets\` = ต้นฉบับ ห้ามแก้ / `Desktop\Game Assets\` = รูปที่เปลี่ยนชื่อ + จัด canvas แล้ว (มี `note.txt` บอกเลขเฟรมต้นฉบับ) ก่อนก๊อปเข้าเกม (ดู 3.22)

**กติกาตั้งชื่อ:**
- ไอเทม 1 ชิ้น = 1 โฟลเดอร์รูป (`icon.png` + โฟลเดอร์ `m/` `f/` เก็บเฟรมทุกท่า) + ไฟล์ใน `items/`
- อาวุธแยกชนิดเป็นโฟลเดอร์ `weapons/<ชนิด>/<เลข>/` ทั้งรูปและไฟล์ไอเทม ไฟล์ข้างในชื่อแค่ `1.tres`, `1_frames_m.tres` (โฟลเดอร์บอกแล้วว่าเป็นอะไร)
- `item_name` (ชื่อบนปุ่มกระเป๋า) แยกจากชื่อไฟล์ เช่น ไฟล์ `sword/1/1.tres` ชื่อไอเทม `sword_1`
- ของที่แยกเพศลงท้ายด้วย `_m` / `_f` เสมอ (ทั้งไฟล์และชื่อตัวแปร `sprite_frames_male` / `sprite_frames_female`) อ่านแล้วรู้ทันทีว่าของเพศไหน
- ใช้**เลขล้วน** ไม่เติม 0 นำหน้า (`1`, `2` ไม่ใช่ `01`) และใช้แบบเดียวกันทั้งชุดและอาวุธ
- ชื่อเฟรมตามท่า `<ท่า>_<ลำดับ>.png` (`idle_0`, `walk_5`) อ่านง่ายกว่าเลข `0.png`-`57.png` ของ asset ดิบ

### 3.2 สร้างตัวละคร Player
1. New Scene → Root Type = **CharacterBody2D** (ไม่ใช่ Node เฉยๆ — เลือกผิดแล้วแก้ทีหลังด้วย **Change Type...** ได้)
2. เพิ่มลูก: `AnimatedSprite2D` (ภาพ), `CollisionShape2D` (ขอบเขตชน, Shape = RectangleShape2D)
3. เพิ่ม `Camera2D` เป็นลูกด้วย (ต้องมี ไม่งั้นมองไม่เห็นอะไร)

### 3.3 นำเข้า Sprite Sheet (asset 60 เฟรม)
- ก็อปไฟล์รูปเข้า `entities/player/sprites/base_body_m/`
- สร้าง **SpriteFrames** resource ในช่อง Sprite Frames ของ AnimatedSprite2D
- ลากรูปทั้งหมดเข้า animation `default` ก่อน แล้วค่อยแยกเป็น animation ย่อยตามท่าทาง (ดูจาก thumbnail จริงในเอดิเตอร์ ง่ายกว่าดูรูปนิ่งทีละภาพ)
- แยกได้: `idle` (0-2), `walk` (3-8), `dash` (9-11), `jump` (12-14) — ท่าที่เหลือ (15-59) ปล่อยไว้ก่อนตาม YAGNI จนกว่าจะต้องใช้จริง

### 3.4 สคริปต์เดิน (เวอร์ชัน top-down เริ่มต้น แล้วเปลี่ยนเป็น platformer)
เริ่มจากเข้าใจผิดว่าเป็นเกม top-down (เดิน 8 ทิศ ไม่มีแรงโน้มถ่วง) แต่เกมแบบ **Ghost Online/MapleStory คือ side-view platformer** (เดินซ้าย-ขวา มีแรงโน้มถ่วง กระโดดได้) ต้องรื้อโค้ดใหม่

โค้ดสุดท้าย (`player.gd`):
```gdscript
extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.6
var facing_direction: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: StatsData

func _physics_process(_delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= _delta

	if not is_on_floor():
		velocity.y += gravity * _delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		facing_direction = sign(direction)

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown

	if is_dashing:
		velocity.x = facing_direction * dash_speed
		dash_timer -= _delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity.x = direction * speed

	move_and_slide()

	animated_sprite.flip_h = facing_direction < 0

	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
```

**concept สำคัญที่ใช้:**
- `is_on_floor()` — เช็คว่ายืนบนพื้นไหม (ผลจาก `move_and_slide()` ครั้งล่าสุด)
- `Input.get_axis(neg, pos)` — คืนค่า -1 ถึง 1 สำหรับการเคลื่อนที่ 1 แกน (ต่างจาก `get_vector` ที่ใช้ 2 แกนสำหรับ top-down)
- `Input.is_action_just_pressed()` vs `is_action_pressed()` — `just_pressed` = true แค่เฟรมแรกที่กด ป้องกันกระโดด/พุ่งซ้ำตอนกดค้าง
- `sign(x)` — แปลงเป็น 1/-1/0 เก็บทิศทางล่าสุดไว้ใช้ตอนไม่มี input (เช่นตอนพุ่ง)
- ลำดับความสำคัญของ animation: `is_dashing` > `not is_on_floor()` > `direction != 0` > idle

### 3.5 สร้างด่านทดสอบ (`village.tscn`)
- Scene ใหม่ Root = `Node2D` ชื่อ `Village`
- `StaticBody2D` (`Wall`) + `CollisionShape2D` เป็นพื้น/กำแพงทดสอบ
- **Instantiate Child Scene** เอา `player.tscn` มาวางเป็นลูกของ Village
- ตั้ง `village.tscn` เป็น **Main Scene** ใน Project Settings → Application → Run

### 3.6 ระบบ Stats แบบ data-driven
- สร้าง `data/stats_data.gd` — `extends Resource` + `class_name StatsData`
- เก็บ `level, exp, exp_to_next_level, max_hp, hp, max_mp, mp` เป็น `@export var`
- เพิ่ม `@export var stats: StatsData` ใน `player.gd`
- สร้างไฟล์ `.tres` จริง (`player_stats.tres`) ผูกเข้า Player ผ่าน Inspector — เซฟแยกไฟล์ (ไม่ฝังใน .tscn) เพื่อให้ระบบ Save/Load ดึงมาแก้ได้ง่ายทีหลัง

### 3.7 HUD แสดงหลอด HP (`ui/hud/hud.tscn`)
- Scene ใหม่ Root = **CanvasLayer** (ตรึงกับจอ ไม่ขยับตามกล้อง/โลกเกม ต่างจาก Node2D)
- เพิ่มลูก `ProgressBar` (มี `min_value`/`max_value`/`value` ในตัว วาดหลอดให้อัตโนมัติ)
- สคริปต์ `hud.gd`:
```gdscript
extends CanvasLayer

@export var stats: StatsData
@onready var hp_bar: ProgressBar = $HpBar

func _ready() -> void:
	if stats == null:
		return
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.hp
```
- **หลักการ:** HUD รับแค่ `StatsData` resource ไปแสดง ไม่อ้างอิงถึง node `Player` ตรงๆ (ถ้า Player ถูกลบ HUD ไม่พังตาม)
- Instance `hud.tscn` เข้า `village.tscn` เป็นลูกของ `Village` แล้วผูก property **Stats** เป็น `.tres` **ไฟล์เดียวกัน**กับที่ผูกไว้ที่ Player (ไม่ใช่สร้างใหม่ ไม่งั้นข้อมูลจะคนละชุดกัน)
- **ข้อจำกัดตอนนี้:** โชว์ค่าแค่ตอน `_ready()` ครั้งเดียว ยังไม่ live-update เพราะยังไม่มีระบบต่อสู้ให้ HP เปลี่ยน — พอทำ combat จะกลับมาเพิ่ม signal ทีหลัง

**Control node ต้องรู้:** ProgressBar/Control มี **Minimum Size** จาก Theme เริ่มต้น ถ้าตั้ง Size เล็กกว่าค่าต่ำสุด (เช่นตั้ง height 24 ทั้งที่ขั้นต่ำ 27) Godot จะดันกลับไปที่ค่าต่ำสุดอัตโนมัติ ไม่ใช่บั๊ก

### 3.8 ระบบต่อสู้พื้นฐาน (Dummy เป้านิ่ง)

**สถาปัตยกรรม:** local/single-player ล้วนๆ ตอนนี้ (คำนวณ damage ฝั่ง client ตรงๆ) — ตาม docs Phase 1 บอกไว้ไม่ต้องคิดเรื่อง server-authority จนกว่าจะถึง Phase 3

- เพิ่ม `attack_power: int = 10` เข้า `StatsData` เดิม (ใช้ resource เดียวกัน ไม่แยกไฟล์ใหม่)
- เพิ่ม Input Action `attack` (ปุ่ม Z) ผ่าน Project Settings → Input Map (ไม่มีให้มาเป็นค่าเริ่มต้นเหมือน `ui_*`)
- Player มี **`AttackArea` (Area2D + CollisionShape2D)** เป็นลูก อยู่ห่างจากตัว `(20, 0)` — ตำแหน่ง x สลับเป็นบวก/ลบตาม `facing_direction` ทุกเฟรม เพื่อให้กล่องโจมตีอยู่ด้านหน้าเสมอไม่ว่าจะหันซ้ายขวา
- `Dummy` (`entities/dummy/dummy.tscn`) = `StaticBody2D` + `StatsData` ของตัวเอง (`dummy_stats.tres`) มีฟังก์ชัน `take_damage(amount)` ลด HP แล้วเช็คตาย → `queue_free()`
- Player เรียก `attack_area.get_overlapping_bodies()` ตอนกดปุ่ม `attack` วนเช็คว่า body ไหนมีฟังก์ชัน `take_damage` (เช็คด้วย `has_method()` กันเรียกฟังก์ชันที่ไม่มีจริง) แล้วส่ง `stats.attack_power` เข้าไปเป็นดาเมจ

**concept ใหม่ที่ใช้:**
- `Area2D` ต่างจาก `CollisionShape2D` บน CharacterBody2D/StaticBody2D ตรงที่แค่ "ตรวจจับการทับซ้อน" ไม่ผลัก/ไม่หยุดการเคลื่อนที่จริง เหมาะกับ hitbox/hurtbox/trigger
- `body.has_method("ชื่อฟังก์ชัน")` — เช็คก่อนเรียกฟังก์ชันแบบไดนามิก ป้องกัน error ถ้า body ที่ทับซ้อนไม่มีฟังก์ชันนั้นจริง (เช่นไปโดนกำแพงที่ไม่มี `take_damage`)
- **ตั้งชื่อตัวแปรชนกับฟังก์ชัน built-in ได้แบบไม่มี error แต่มี warning**: ตั้ง `exp` ใน StatsData ชนกับ `exp()` (ฟังก์ชันเลขยกกำลัง e ของ GDScript) — ไม่พังแต่ควรเปลี่ยนชื่อเป็น `experience` กันสับสน

**Animation "attack" ผูกเข้ากับ state:** ใช้ pattern เดียวกับ `is_dashing`/`dash_timer` เป๊ะๆ — เพิ่ม `is_attacking`/`attack_timer`/`attack_duration` แล้วจัดลำดับ priority animation ใหม่: `is_dashing > is_attacking > not is_on_floor() (jump) > direction != 0 (walk) > idle`. เลือกเฟรมท่าโจมตีจาก asset โดยดูรูปย่อ (thumbnail) จริงในหน้าต่างเลือกไฟล์ (สลับจาก List view เป็น Grid/Thumbnail view ที่มุมบนขวาของ FileDialog) แทนการเดาจากชื่อไฟล์ตัวเลข

### 3.9 ระบบ Equipment (ชุดเกราะ + อาวุธ)

**สถาปัตยกรรมข้อมูล:** `data/equipment_data.gd` (`class_name EquipmentData extends Resource`)
```gdscript
extends Resource
class_name EquipmentData

@export var id: int
@export var item_name: String
@export var icon: Texture2D
@export_enum("weapon", "armor", "face", "hat") var slot: String = "weapon"
@export var attack_bonus: int = 0
@export var sprite_frames: SpriteFrames
@export var attack_range: float = 0.0 # 0 = ใช้ระยะหมัด
@export_enum("melee", "projectile") var attack_type: String = "melee"
@export var projectile_scene: PackedScene
```
- `@export_enum(...)` ทำให้ช่องใน Inspector เป็น**เมนูเลือก** แทนช่องพิมพ์ ป้องกันพิมพ์ผิด/มีช่องว่างเกิน (บั๊กแบบ `"idle "`) — ค่าที่เก็บยังเป็น String เหมือนเดิม ไฟล์ `.tres` เก่าใช้ต่อได้
ไฟล์ `.tres` จริง (ตัวข้อมูล ไม่ใช่แม่แบบ) เก็บที่ **`items/`** แยกจาก `data/` (แม่แบบสคริปต์) ส่วนไฟล์รูปอยู่ `entities/player/sprites/armor/<เลข>/`, `.../weapons/<เลข>/` (ดูโครงสร้างที่ 3.1)

อาวุธก็มี `sprite_frames` ได้เหมือนชุด (ถ้ามีเฟรมดาบในมือ) — ไม่ต้องแยก field

**Layered Sprite (ซ้อนหลายเลเยอร์บน Body):**
```
Player (CharacterBody2D)
├── AnimatedSprite2D   ← Body (ผู้คุมเฟรม)
├── FaceSprite         ← หน้า (ดู 3.13)
├── ArmorSprite        ← ชุด (ลำดับในลิสต์ = ลำดับการวาด ตัวล่างวาดทับตัวบน)
├── HatSprite          ← หมวก (ดู 3.17)
├── WeaponSprite       ← ดาบ วาดทับทุกอย่าง
├── CollisionShape2D
├── Camera2D
└── AttackArea
```
- ทุกเลเยอร์อยู่ตำแหน่ง **`(0, 0)`** ใช้ **Centered = true** (ค่า default) — ไม่ต้องมี offset ในโค้ด เพราะรูปถูกจัดให้กรอบตรงกับรูปตัวมาตั้งแต่ใน Aseprite
- **node เลเยอร์ต้องว่างใน scene** (ไม่ตั้ง Sprite Frames ไว้ล่วงหน้า) — รูปจะมาจาก `EquipmentData` ตอนกดใส่ ถ้าตั้งค้างไว้ จะโชว์ภาพนิ่งทั้งที่ยังไม่ได้ใส่ของ (ขึ้น ⚠️ "no SpriteFrames" ในเอดิเตอร์เป็นเรื่องปกติ)
- ชื่อท่าใน SpriteFrames ของเลเยอร์ต้องตรงกับ Body (`idle`, `walk`, ...) ถ้าเลเยอร์ไหน**ยังไม่มีท่านั้น** โค้ดจะซ่อนเลเยอร์นั้นแทนที่จะขึ้น error (ทำเฟรมเพิ่มทีละท่าได้)

**โค้ด sync ทุกเลเยอร์ (แบบถูกหลักการ):** (ส่วนใส่/ถอดของดู 3.11, ตารางช่อง `slot_sprites` ดู 3.17)
```gdscript
func _ready() -> void:
	animated_sprite.frame_changed.connect(_sync_layers)
	animated_sprite.animation_changed.connect(_sync_layers)
	...

func _sync_layers() -> void:
	for layer in [face_sprite] + slot_sprites.values():
		_sync_layer(layer)

func _sync_layer(layer: AnimatedSprite2D) -> void:
	var anim := animated_sprite.animation
	if layer.sprite_frames and layer.sprite_frames.has_animation(anim):
		layer.visible = true
		layer.animation = anim
		layer.frame = animated_sprite.frame
	else:
		layer.visible = false
```
และใน `_physics_process` พลิกทุกเลเยอร์พร้อมตัว:
```gdscript
	for sprite in [animated_sprite, face_sprite] + slot_sprites.values():
		sprite.flip_h = facing_direction < 0
```
- **หลักการ:** ตัว (Body) เป็นเจ้าของเฟรมคนเดียว (single source of truth) เลเยอร์อื่นแค่ลอกตาม และใช้ **signal** (ยิงทันทีตอนตัวเปลี่ยนเฟรม) แทนการเช็คทุกเฟรม → ตรงกันเป๊ะ ไม่มีช่องว่างให้กระพริบ
- **ห้ามใส่ Sprite Frames ให้ node เลเยอร์ใน Inspector เพื่อลองดู** — node จะจำชื่อท่าค้างไว้ในไฟล์ scene (เช่น `animation = &"idle "`) แล้วขึ้น error `set_animation: There is no animation with name ...` ทุกครั้งที่รันเกม ถ้าอยากดูตัวอย่างให้เปิดไฟล์ `*_frames.tres` ในแผง SpriteFrames แทน ถ้าเกิดแล้ว แก้โดยลบ node แล้วสร้างใหม่ชื่อเดิม

**ดาบติดมือ:** asset ที่มีเป็นแค่ไอคอนนิ่ง (`Weapons.png` ตาราง 31x31 ช่องละ 38px) ไม่มีเฟรมตามท่า → ทำเองใน Aseprite: วางไอคอนบนเลเยอร์ใหม่เหนือรูปตัว ขยับ/หมุนให้อยู่ในมือทีละเฟรม แล้ว export แบบเดียวกับชุด
- หมุนใน Aseprite: ตอนภาพยังลอยอยู่ พิมพ์องศาในช่อง `R:` หรือลากจากนอกมุมกรอบ, พลิก Shift+H / Shift+V
- เปลี่ยนโหมดหมุนจาก `Fast Rotation` เป็น **`RotSprite`** ก่อนหมุน ไม่งั้นขอบภาพ pixel art แตกหยัก
- หาช่องไอคอนในตารางใหญ่: เรนเดอร์ช่องพร้อมเลข `แถว,คอลัมน์` กำกับแล้วมองหาด้วยตา (การเทียบภาพอัตโนมัติพลาดง่ายถ้าภาพอ้างอิงถูกขยาย/ครอปต่างกัน) — ต้องวัดขนาดช่องจริงก่อน (หาแถว/คอลัมน์ที่โปร่งใสทั้งแถว) อย่าเดา เช่นตารางหน้าเป็นช่องละ 36px ไม่ใช่ 32
- **ทางลัดทำเฟรมดาบ:** ทำ `idle_0` เองใน Aseprite 1 เฟรม แล้วให้สคริปต์ Python ย้ายดาบรูปเดิมไปวางที่มือของทุกเฟรม (อ่านตำแหน่งมือจากรูปที่ใส่เส้นตาราง) — ได้ครบ 19 เฟรมในไม่กี่วินาที แต่ดาบเอียงมุมเดียวตลอด ท่าฟันต้องหมุนเองในเฟรม attack
  - การหามือแบบอัตโนมัติ (เทียบลายสีผิว) **ไม่แม่น** ไปจับเท้าแทน เพราะสีเดียวกัน → ใช้คนอ่านพิกัดจากภาพที่มีเส้นตาราง
  - ไฟล์ที่ได้เก็บไว้ที่ `Desktop\assets\sword_frames\` (นอกโปรเจกต์) ใช้เป็นจุดเริ่มต้นได้
- **บทเรียน git:** ไฟล์ที่ยังไม่ได้ commit ถ้าย้อนด้วย git จะหายถาวร — ก่อนให้สคริปต์เขียนไฟล์ทีละเยอะลงโปรเจกต์ ให้ commit ก่อน หรือสร้างลงโฟลเดอร์นอกโปรเจกต์ให้ตรวจก่อน

**เตรียมรูปใน Aseprite (ทำครั้งเดียวต่อเฟรม ต่อชุด):**
1. เปิดรูปตัว (Base Body) เป็นฐาน
2. Sprite → Canvas Size เติมขอบ **ซ้าย=ขวา** (เท่ากันเสมอ ไม่งั้นพลิกซ้าย-ขวาแล้วเยื้อง) บน/ล่างไม่เท่ากันได้แต่ต้องชดเชย y และใช้ค่าเดียวกันทุกเฟรม — ง่ายสุดคือเท่ากันทุกด้าน
3. Layer → **New Layer** ก่อน แล้วค่อย Ctrl+V วางชุด (ไม่งั้นวางทับลงเลเยอร์ตัว)
4. ลด Opacity หรือใช้ Blend mode = Difference เลเยอร์ชุด → เลื่อนด้วยลูกศรทีละพิกเซลจนตรง → Enter
5. ซ่อนเลเยอร์ตัว → File → Export As → **Area: Canvas**, Resize 100%, Layers: Visible → เซฟ
6. export รูปตัวด้วยกรอบเดียวกัน (หรือใช้กรอบเดิมถ้าเติมขอบเท่ากันทุกด้าน) → รูปตัว/ชุดเฟรมเดียวกันต้องมี**ขนาดกรอบเท่ากัน**
- ไม่แก้ไฟล์ Base Body ต้นฉบับ (ไม่กด Ctrl+S ทับ) — canvas ที่ขยายเป็นแค่พื้นที่ทำงาน
- ถ้า asset ในอนาคตเป็นแบบ**ไม่ตัดขอบ** (ทุกเฟรมกรอบเท่ากัน) ข้ามขั้นตอนนี้ได้เลย ซ้อนตรงทันที

- `equip_weapon()` คำนวณ `stats.attack_power = base_attack_power + item.attack_bonus` (เก็บ `base_attack_power` แยกไว้ป้องกันบวกทบตอน equip ซ้ำ)
- อาวุธที่มีแค่ **ไอคอนแบน** (ไม่ใช่ชุดเฟรม 58 ภาพเหมือนชุดเกราะ) จะมีผลแค่ "สถิติ" เท่านั้น ไม่มีภาพติดมือให้เห็นในเกม — ต้องมี asset เป็นชุดเฟรมสอดคล้องท่าทางเหมือนชุดเกราะถึงจะทำภาพติดมือได้

**ปัญหาที่เจอ + บทเรียน:**
- **แก้ property ตอนเกมกำลังรันอยู่ (Play mode) ไม่ติดถาวร** — ค่าที่แก้ระหว่างรันเป็นแค่ preview ชั่วคราว ต้อง **หยุดเกม (F8) ก่อนแก้ แล้วเซฟ** ถึงจะติดถาวร (พฤติกรรมปกติของ Godot ไม่ใช่บั๊ก)
- **ตำแหน่งซ้อนภาพ 2 เลเยอร์ไม่ตรงกัน เพราะ asset ถูกตัดขอบ (trim) ไม่เท่ากันทุกเฟรม** — เฟรม idle ติดกัน (0,1,2) กรอบสูงไม่เท่ากัน (77/78/79) ค่า offset เดียวใช้ไม่ได้ทุกท่า (วัดจริง: ส่วนใหญ่ต้องลง ~11px แต่ท่า dash ต้อง ~6px, แกน x แกว่ง ±1-3px) → **แก้ที่ต้นเหตุคือจัดกรอบรูปให้ตรงกันใน Aseprite** ไม่ใช่ไล่ปรับ offset ในโค้ด
- ~~คูณ offset ด้วย `facing_direction`~~ — เป็นแค่การปะปัญหา ใช้ได้เฉพาะท่าเดียว เลิกใช้แล้วหลังจัดกรอบรูปให้ตรง (กรอบเท่ากัน กึ่งกลางเดียวกัน พลิกรอบจุดเดียวกัน ตรงเองอัตโนมัติ)
- **ชุดกระพริบ / ผิวโผล่ๆ หายๆ** — ที่เคยสรุปว่าเป็น "seam ในอาร์ต" **ผิด** สาเหตุจริงมี 3 อย่าง:
  1. **ชุดกับตัวนับเฟรมแยกกัน** (ต่างคน `play()` เอง) → เฟรมเหลื่อม (เช็คสดเจอ: ตัวเฟรม 1 ชุดเฟรม 0) → แก้ด้วยให้ชุดลอกเฟรมจากตัว
  2. **ลอกเฟรมใน `_physics_process` แต่ตัวเปลี่ยนเฟรมใน `_process`** → จังหวะไม่ตรง ชุดช้ากว่าแวบนึงทุกครั้งที่เปลี่ยนเฟรม (ท่าเดินเห็นชัด ท่ายืนไม่ค่อยเห็นเพราะเฟรมหน้าตาใกล้กัน) → แก้ด้วย signal `frame_changed`/`animation_changed`
  3. **Texture Filter = Linear (ค่าเริ่มต้น)** + รูปขนาดคี่ตกครึ่งพิกเซล → สีผสมเพี้ยนไปมา → แก้ใน Project Settings (ดูด้านล่าง)
- **ลืมลบ `play()` ออกจุดหนึ่ง = 2 ตัวแย่งกันคุมเฟรม กระพริบหนักกว่าเดิม** — เวลาเปลี่ยนวิธีคุม ต้องเปลี่ยนให้ครบทุกจุดที่เรียก (ใน `_physics_process` และใน `equip_armor()`)
- **แก้โค้ดตามคำสั่ง "เพิ่มบรรทัด" แต่ไปแทนที่บรรทัดเดิม** (ลบ `armor_sprite.flip_h` ทิ้งโดยไม่ตั้งใจ) → ชุดไม่พลิกตาม — เช็คโค้ดทั้งช่วงหลังแก้ทุกครั้ง
- **ภาพเทียบ 2 ทิศทาง ต้องดูส่วนที่เป็นของเลเยอร์นั้นจริงๆ** — เท้าเปล่าที่สลับข้างเป็นของ Body ไม่ได้พิสูจน์ว่า Armor พลิก ต้องดูรายละเอียดที่อยู่บนชุดเอง

**Project Settings สำหรับเกม pixel art (ตั้งครั้งเดียว ทุกโปรเจกต์):**
- Rendering → Textures → Canvas Textures → **Default Texture Filter = Nearest** (ไม่งั้นภาพเบลอ สีเพี้ยนตอนตกครึ่งพิกเซล)
- Rendering → 2D → Snap → **Snap 2D Transforms to Pixel = On**
- ตำแหน่ง node ของ sprite ควรเป็น**เลขเต็ม** ไม่ใช่ทศนิยม (เช่น 11 ไม่ใช่ 11.2)
- **debug flag อย่าง "Visible Collision Shapes" มีผลแค่ตอนเริ่มเกมใหม่** เปลี่ยนตอนเกมรันอยู่แล้วจะไม่มีผลจนกว่าจะ stop + run ใหม่
- **วิธี debug ที่ได้ผลดีที่สุดตอนเถียงกันว่า "เห็น/ไม่เห็น" อะไร:** ถ่าย screenshot จริงจากเกม (`editor_screenshot` source="game") แล้ว crop+ขยายด้วย Python (PIL) ดูพิกเซลจริงชัดๆ แทนการเดาจากคำบรรยาย

### 3.10 เครื่องมือเสริม: Aseprite + aseprite-mcp
- **Aseprite** = โปรแกรมวาด/จัดการ pixel art (ติดตั้งที่ `C:\Programs\Aseprite`) ใช้จัดกรอบรูปชุดให้ตรงกับตัว
- **aseprite-mcp** (github.com/diivi/aseprite-mcp) = MCP server ให้ Claude สั่ง Aseprite ได้ (สร้าง canvas, import เลเยอร์, ขยับ, export) — clone ไว้ที่ `C:\Users\fF\mcp-servers\aseprite-mcp`, ต้องมี `uv` + ตั้ง `ASEPRITE_PATH`
- ไฟล์ที่ MCP สร้างจะไปอยู่ในโฟลเดอร์ของ server เอง (ไม่ใช่ในโปรเจกต์เกม) ต้องย้ายเข้าเอง
- **บทเรียนติดตั้ง:** เพิ่มด้วย `claude mcp add` แบบ scope `local` (ค่าเริ่มต้น) แล้วไม่ยอมโหลด เพราะเทียบ path โปรเจกต์ตัวพิมพ์ใหญ่-เล็กไม่ตรง (`c:\` vs `C:\`) → แก้โดยเพิ่มแบบ `-s user` (global เหมือน godot-ai) แล้ว **Reload Window** ใน VSCode (แค่เปิดแชทใหม่ไม่พอ ต้องเริ่ม process ใหม่)
- **ไม่ควรเก็บ config MCP ใน `.mcp.json` ของโปรเจกต์** เพราะมี path เฉพาะเครื่อง และเป็นเครื่องมือช่วยทำงาน ไม่ใช่ส่วนของเกม
- **เทคนิคที่ใช้หาตำแหน่งจริง:** เขียน Python (PIL + numpy) คำนวณ offset "เท้าชุดตรงเท้าตัว" ทุกเฟรม แล้วเรนเดอร์ภาพรวม (contact sheet) ออกมาดูทีเดียวทุกท่า — เร็วกว่าลองผิดลองถูกทีละค่าในเกม

### 3.11 UI Inventory (กด I เปิดกระเป๋า, กดไอเทม = ใส่ / กดซ้ำ = ถอด)

**การออกแบบ:** UI กับ Player ไม่รู้จักกันตรงๆ คุยกันผ่าน Resource กระเป๋าไฟล์เดียวกัน (แบบเดียวกับ HUD ↔ StatsData) และ **"ของที่ใส่อยู่" เก็บใน InventoryData** ไม่ใช่ใน Player — กระเป๋าเป็นเจ้าของข้อมูลคนเดียว UI จึงรู้ว่าชิ้นไหนใส่อยู่ และตอนทำ Save/Load เซฟไฟล์เดียวได้ทั้งของในกระเป๋าและของที่ใส่
```
InventoryData (player_inventory.tres) ← items + equipped (ช่อง → ไอเทม) + signal equipment_changed
   ↑ InventoryUI: กดปุ่ม = toggle_equip(item), ปุ่มของที่ใส่อยู่ค้างเป็นกดไว้
   ↑ Player: ฟัง equipment_changed → เปลี่ยนภาพเลเยอร์ (ไม่เก็บสถานะเอง)
```
ลบ UI ทิ้ง Player ยังทำงานได้ปกติ

`data/inventory_data.gd`:
```gdscript
extends Resource
class_name InventoryData

signal equipment_changed(slot: String, item: EquipmentData)

@export var items: Array[EquipmentData] = []
var equipped: Dictionary = {}

func toggle_equip(item: EquipmentData) -> void:
	if is_equipped(item):
		equipped.erase(item.slot)
		equipment_changed.emit(item.slot, null)
	else:
		equipped[item.slot] = item
		equipment_changed.emit(item.slot, item)

func is_equipped(item: EquipmentData) -> bool:
	return equipped.get(item.slot) == item

func get_attack_bonus() -> int:
	var total := 0
	for item in equipped.values():
		total += item.attack_bonus
	return total
```
- `equipped` เป็น Dictionary ใช้ชื่อช่องเป็นกุญแจ แต่ละช่องใส่ได้ชิ้นเดียว ใส่ชิ้นใหม่ = ทับชิ้นเก่าอัตโนมัติ
- ถอด = ส่ง signal โดยให้ `item` เป็น `null`

Player: `@export var inventory: InventoryData` + ใน `_ready()` `inventory.equipment_changed.connect(_on_equipment_changed)` (โค้ด `_on_equipment_changed` ดู 3.17)

`ui/inventory/inventory_ui.tscn`: `InventoryUI (CanvasLayer) > Panel (PanelContainer, %) > Grid (GridContainer, columns 4, %)`
```gdscript
extends CanvasLayer

@export var inventory: InventoryData
@onready var panel: PanelContainer = %Panel
@onready var grid: GridContainer = %Grid

func _ready() -> void:
	panel.visible = false
	inventory.equipment_changed.connect(_on_equipment_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		panel.visible = not panel.visible
		if panel.visible:
			_refresh()

func _on_equipment_changed(_slot: String, _item: EquipmentData) -> void:
	if panel.visible:
		_refresh()

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	for item in inventory.items:
		var button := Button.new()
		button.text = item.item_name
		button.icon = item.icon
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.button_pressed = inventory.is_equipped(item)
		button.pressed.connect(inventory.toggle_equip.bind(item))
		grid.add_child(button)
```
- `toggle_mode` ปุ่มกดค้างได้ ใช้แสดงว่าชิ้นไหนใส่อยู่
- `focus_mode = FOCUS_NONE` ปุ่มกดได้ด้วยเมาส์อย่างเดียว ไม่ถือ focus ค้าง — ไม่งั้นกด Space (กระโดด) ปุ่มที่ถูกคลิกไว้จะถูกกดไปด้วย
- ฟัง `equipment_changed` แล้ว refresh ใส่ชุดใหม่ทับชุดเก่า ปุ่มชุดเก่าจะเด้งออกเอง
- Instance เข้า `village.tscn` แล้วผูก Inventory เป็น `.tres` **ไฟล์เดียวกับที่ผูกใน Player**
- Input Action `inventory` = ปุ่ม I
- **concept ใหม่:** `%Name` (Unique Name — คลิกขวา node → Access as Unique Name) อ้างถึง node ได้แม้ย้ายตำแหน่งในโครง, `Button.new()` สร้างปุ่มด้วยโค้ดเมื่อจำนวนไม่คงที่, `Callable.bind(ค่า)` ผูกค่าติดไปกับฟังก์ชันล่วงหน้า
- ลบ `starting_armor` / `starting_weapon` ออกจาก Player แล้ว (เคยใช้ทดสอบตอนยังไม่มีกระเป๋า)
- ยังไม่ทำ: ลากวางย้ายช่อง, จำกัดช่อง

**ปัญหาที่เจอ + บทเรียน:**
- **ปุ่มไม่มีรูป** = ไอเทมยังไม่ได้ตั้ง `icon` ในไฟล์ `.tres` (ไม่ใช่ปัญหาโค้ด)
- **ลบ Sprite Frames ออกจาก node แล้วขึ้น error `set_animation: There is no animation with name 'attack'`** = node ยังจำค่า Animation เดิมไว้ในไฟล์ scene พอกด Revert ก็กลายเป็น `animation = &""` ยังขึ้น error อยู่ (Inspector เลือกชื่อท่าไม่ได้เมื่อไม่มี SpriteFrames) → **แก้ด้วยลบ node แล้วสร้างใหม่ชื่อเดิม** (node ใหม่ไม่มีค่าค้าง) หรือลบบรรทัด `animation = ...` ในไฟล์ `.tscn` ตรงๆ (ต้องปิดแท็บ scene ใน Godot ก่อน ไม่งั้นมันเซฟทับกลับ)
- **error `Identifier "..." not declared` ค้างใน log** มักเป็นของตอนพิมพ์โค้ดไปได้ครึ่งเดียว เช็คโค้ดปัจจุบันก่อนตื่นตกใจ

### 3.12 เปลี่ยนชื่อ/ย้ายไฟล์โดยไม่ทำให้ลิงก์พัง
- **ย้ายผ่าน Godot** (ลากในแผง FileSystem / คลิกขวา Rename / MCP `filesystem_manage op=move`) ไม่ใช่ย้ายด้วย File Explorer หรือคำสั่ง shell — Godot อ้างอิงไฟล์ด้วย **uid** เลยยังหาเจอหลังย้าย
- แต่ข้อความ `path="res://..."` ในไฟล์ `.tres` ที่อ้างถึงอาจยังเป็นชื่อเก่า (ทำงานได้เพราะใช้ uid แต่มี warning และอ่านแล้วงง) → **ค้นหาชื่อเก่าทั้งโปรเจกต์แล้วแก้ให้ตรง** จนค้นไม่เจอ แล้วสั่ง scan ใหม่
- ปิดแท็บไฟล์ที่เกี่ยวข้องใน Godot ก่อนแก้ข้อความในไฟล์ ไม่งั้น Godot อาจเซฟ path เก่าทับกลับ
- ห้ามลบไฟล์ `.uid` / `.import` ทิ้งเองตอนย้าย (ดู 5.10)

### 3.13 หน้าตาตัวละคร (Face) — ไม่ใช่ของในกระเป๋า แต่เก็บเป็นไอเทม
> โค้ด/ชื่อไฟล์ในหัวข้อนี้เป็นเวอร์ชันแรก — ปัจจุบัน `_apply_appearance` ถูกแทนด้วย `_refresh_sprites` และไฟล์แยกเพศแล้ว (ดู 3.19)

**การออกแบบ:** หน้าเป็น "หน้าตาตัวละคร" ผู้เล่นเปลี่ยนได้ตลอด เก็บใน Resource แยก `AppearanceData` แต่ตัวหน้าเองเก็บเป็น `EquipmentData` (slot = `face`) — วันหน้าอยากให้เป็นของในกระเป๋า/ร้านค้า ก็แค่เพิ่มลง `player_inventory.tres` ไม่ต้องสร้างข้อมูลใหม่
```
items/face/face_1.tres, face_1_frames.tres    ← ไอเทมหน้า + SpriteFrames
entities/player/player_appearance.tres       ← AppearanceData.face → face_1.tres
entities/player/sprites/face/1/               ← icon.png + เฟรม
```
`data/appearance_data.gd`:
```gdscript
extends Resource
class_name AppearanceData

@export var face: EquipmentData:
	set(value):
		face = value
		emit_changed()
```
Player:
```gdscript
@onready var face_sprite: AnimatedSprite2D = $FaceSprite
@export var appearance: AppearanceData

# ใน _ready()
	appearance.changed.connect(_apply_appearance)
	_apply_appearance()

func _apply_appearance() -> void:
	face_sprite.sprite_frames = appearance.face.sprite_frames if appearance.face else null
	_sync_layers()
```
- **setter** `set(value):` โค้ดที่ทำงานทุกครั้งที่ค่าเปลี่ยน — ใช้เรียก `emit_changed()` ส่ง signal `changed` ที่ Resource ทุกตัวมีอยู่แล้ว
- `A if เงื่อนไข else B` เลือกค่าในบรรทัดเดียว กันพังตอนยังไม่มีหน้า (`null`)

**เตรียมรูปหน้า:**
- asset หน้าเป็นไอคอน**หัวทั้งหัว หันซ้าย** 36x36 → พลิกซ้าย-ขวาให้หันขวาตามตัวละคร
- ไอคอนหัวเล็กกว่าหัวตัวละคร วางทับแล้วเห็นเส้นขอบหัวซ้อน → ลบเส้นขอบดำฝั่งหูออก แล้ววางใน Aseprite ให้ตา-ปากตรงหัว
- **หัวตัวละครเป็นรูปเดียวกันทุกท่า** ต่างกันแค่ตำแหน่งแนวนอน (jump_1 +8, attack_0/3 +10, dash_1 +16, dash_2 +21, dash_0 +23 พิกเซล ที่เหลืออยู่ที่เดิม) → ทำหน้าแค่ `idle_0` แล้วเลื่อนไปวางเฟรมอื่นตามตัวเลขนี้ได้ (ใช้กับหมวกได้เหมือนกัน)
- การดึงแค่ตา-ปากจากไอคอนแบบอัตโนมัติ **ไม่เวิร์ก** เพราะสัดส่วนหัวไม่เท่ากัน → ทำมือใน Aseprite ดีกว่า

**Aseprite: export แบบไหน**
- เฟรมเกม → **Area: Canvas** + **Layers: เลเยอร์หน้า** = กรอบเท่ารูปตัว ตำแหน่งตรงกับหัวในเกม
- เก็บแค่ตัวหน้าไว้ใช้ซ้ำ → **Area: Selection** (หรือ Edit → Paste Special → Paste as New Sprite)
- **กด Enter วางภาพที่ลอยอยู่ก่อน export เสมอ** และ**ห้าม Ctrl+S** ตอนเปิดรูปตัวต้นฉบับอยู่ ไม่งั้นรูปตัวจะถูกเขียนทับ

**ปัญหาที่เจอ:** ชื่อท่าใน SpriteFrames พิมพ์เป็น `"idle "` (มีช่องว่างท้าย) → ไม่ตรงกับตัว หน้าไม่ขึ้น + node จำชื่อผิดค้างไว้ → error ทุกครั้งที่รัน (แก้: แก้ชื่อท่า + ลบ node สร้างใหม่)

### 3.14 ทบทวนโปรเจกต์ + แก้ตามหลัก Godot (4 ข้อ)
1. **ชื่อช่องไอเทมเป็นข้อความพิมพ์เอง** → เปลี่ยนเป็น `@export_enum` (ดู 3.9)
2. **ปุ่ม Space ชนกันระหว่างกระโดดกับปุ่มในกระเป๋า** และใช้ `ui_*` (ของ Godot สำหรับเลื่อนเมนู) มาเดิน → สร้าง action ของเกมเอง (`move_left`, `move_right`, `jump`) + ปุ่มกระเป๋าตั้ง `focus_mode = FOCUS_NONE`
   - เปลี่ยนแค่ชื่อ action อย่างเดียวไม่พอ เพราะ Space ยังเป็น `ui_accept` ของปุ่มที่ถือ focus อยู่เสมอ
   - ถ้าโค้ดเรียก action ที่ยังไม่ได้สร้าง จะขึ้น error `The InputMap action "jump" doesn't exist.` ทุกเฟรม
3. **มอนสเตอร์ใช้ `.tres` ร่วมกัน → เลือดลดพร้อมกัน** (บั๊กอันดับ 1 ของ Godot 4) → ใน `dummy.gd`:
   ```gdscript
   func _ready() -> void:
   	stats = stats.duplicate()
   ```
   - Resource ที่หลาย node อ้างถึงคือ**ก้อนเดียวกันในหน่วยความจำ** `duplicate()` ทำสำเนาให้แต่ละตัว ไฟล์ `.tres` กลายเป็นแค่**แม่แบบค่าเริ่มต้น**
   - Player **ไม่** duplicate เพราะมีตัวเดียว และตั้งใจให้ HUD ใช้ `player_stats.tres` ก้อนเดียวกัน
   - ใน Inspector: ไอคอน**โซ่** 🔗 = ใช้แม่แบบร่วม (แก้ตรงนี้ = แก้ทุกตัว), **Make Unique** = ตัวนี้มีข้อมูลของตัวเอง (ฝังใน `.tscn`) — ใช้แม่แบบกับตัวธรรมดา, Make Unique กับตัวพิเศษอย่างบอส
4. **ใส่อาวุธแล้วไปเขียนทับ `stats.attack_power`** → ไม่แตะ stats เลย คำนวณตอนโจมตี `damage = stats.attack_power + inventory.get_attack_bonus()` (รวมโบนัสทุกชิ้นที่ใส่อยู่อัตโนมัติ)

### 3.15 ระยะโจมตีตามอาวุธ + ท่าโจมตีเล่นครบ
```gdscript
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@export var unarmed_range: float = 24.0
const ATTACK_START := 8.0
var attack_range: float = 0.0

# ใน _ready()
	attack_shape.shape = attack_shape.shape.duplicate()
	_set_attack_range(unarmed_range)

# ใน _physics_process — ขอบหลังของกล่องติดหน้าตัวเสมอ
	attack_area.position.x = (ATTACK_START + attack_range / 2) * facing_direction

func _set_attack_range(value: float) -> void:
	attack_range = value
	attack_shape.shape.size.x = value
```
ใส่/ถอดอาวุธ → `_set_attack_range(item.attack_range if item and item.attack_range > 0 else unarmed_range)`
- CollisionShape วางจาก**จุดกลาง** กล่องยาวขึ้นต้องเลื่อนจุดกลางออกไปครึ่งหนึ่ง
- `shape.duplicate()` หลักเดียวกับข้อ 3 ของ 3.14 (ไม่แก้ค่าที่บันทึกใน scene)
- `const` = ค่าคงที่ ตั้งชื่อแทนตัวเลขลอยๆ

**ท่าโจมตีเล่นไม่ครบ (4 เฟรมเห็นแค่บางเฟรม):** เดิมตั้ง `attack_duration = 0.3` วินาที แต่ท่า 4 เฟรมที่ 5 FPS ใช้ 0.8 วินาที → เลิกใช้ตัวจับเวลา ให้จบตอนท่าเล่นครบจริง:
- ปิด **Loop** ของท่า `attack` ในแผง SpriteFrames (ถ้า Loop เปิดอยู่จะไม่มี signal จบ)
- `animated_sprite.animation_finished.connect(_on_animation_finished)` แล้ว
```gdscript
func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
```
- อยากตีเร็ว/ช้า ปรับ **FPS** ของท่า attack อย่างเดียว ไม่ต้องแก้โค้ด

### 3.16 อาวุธตีไกล (ธนู/ปืน) — ระบบกระสุน
```
EquipmentData.attack_type = "projectile" + projectile_scene = arrow.tscn
Player._attack(): projectile → _shoot() สร้างกระสุน / melee → เช็คกล่องหน้าตัวเหมือนเดิม
entities/projectiles/projectile.gd (class_name Projectile, Area2D) + arrow.tscn (CollisionShape 16x4)
```
`projectile.gd`:
```gdscript
extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var max_distance: float = 300.0
var direction: float = 1.0
var damage: int = 0
var shooter: Node
var _traveled: float = 0.0

func _ready() -> void:
	scale.x = direction
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var step := speed * delta
	position.x += step * direction
	_traveled += step
	if _traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
```
Player:
```gdscript
func _attack() -> void:
	var damage := stats.attack_power + inventory.get_attack_bonus()
	var weapon: EquipmentData = inventory.equipped.get("weapon")
	if weapon and weapon.attack_type == "projectile":
		if weapon.projectile_scene:
			_shoot(weapon.projectile_scene, damage)
			return
		push_warning("%s: attack_type = projectile แต่ไม่ได้ใส่ projectile_scene" % weapon.item_name)
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _shoot(scene: PackedScene, damage: int) -> void:
	var projectile := scene.instantiate() as Projectile
	projectile.direction = facing_direction
	projectile.damage = damage
	projectile.shooter = self
	projectile.position = position + Vector2(ATTACK_START * facing_direction, -10)
	get_parent().add_child(projectile)
```
- ธนูกับปืนต่างกันแค่ **scene กระสุน** (ความเร็ว ระยะ รูป) โค้ดตัวเดียวกัน, มอนสเตอร์ใช้ `take_damage()` เดิม
- `as Projectile` บอกชนิดจาก `class_name` จะได้ใช้ `.direction`, `.damage` ได้
- ใส่กระสุนในฉาก (`get_parent()`) **ไม่ใส่เป็นลูกของ Player** ไม่งั้นกระสุนเดินตามผู้เล่น
- `shooter` กันกระสุนชนคนยิงเองตอนเกิด
- **ปัญหาที่เจอ:** ตั้ง Attack Type = projectile แต่ลืมใส่ Projectile Scene → `Cannot call method 'instantiate' on a null value` → เพิ่มการเช็ค + `push_warning` (ข้อความเตือนสีเหลือง เกมเล่นต่อได้)

### 3.17 หมวก + ตารางช่อง `slot_sprites` (กำลังทำ)
เพิ่มช่องใหม่ทีไรต้องแก้หลายจุด (if/elif, รายการ sync, บรรทัดพลิก) → เปลี่ยนเป็นตาราง "ช่อง → node" เพิ่มช่องใหม่แค่เพิ่มในตาราง + เมนู Slot
```gdscript
@onready var hat_sprite: AnimatedSprite2D = $HatSprite
@onready var slot_sprites := {"armor": armor_sprite, "hat": hat_sprite, "weapon": weapon_sprite}

func _on_equipment_changed(slot: String, item: EquipmentData) -> void:
	if slot == "weapon":
		_set_attack_range(item.attack_range if item and item.attack_range > 0 else unarmed_range)
	var sprite: AnimatedSprite2D = slot_sprites.get(slot)
	if sprite:
		sprite.sprite_frames = item.sprite_frames if item else null
	_sync_layers()
```
- ต้องประกาศ `slot_sprites` **หลัง** `@onready` ของทุก node ที่อยู่ในตาราง (`@onready` ทำตามลำดับบรรทัด)
- `[a, b] + dict.values()` ต่อรายการ 2 ชุดเพื่อวนลูปเดียว
- node `HatSprite` อยู่ใต้ `ArmorSprite` (หมวกทับชุด ใต้ดาบ)
- รูปหมวก: ทำ `idle_0` ใน Aseprite แล้วเลื่อนตามตำแหน่งหัว (ดู 3.13) เก็บ `sprites/hat/1/m/` → `items/hat/hat_1.tres` + `hat_1_frames_m.tres`
- ⚠️ โค้ดตัวอย่างข้างบนเขียนก่อนมีระบบเพศ — ตอนทำจริงให้ต่อยอดจาก `_refresh_sprites` (3.19) แทน

### 3.18 แยกคลาสไอเทม + ตั้งชื่อ stat ให้เป็นระบบ
**แยกคลาส:** ของที่มีเฉพาะอาวุธ (ระยะ, แบบโจมตี, กระสุน) ย้ายออกจาก `EquipmentData` ไปอยู่ในลูก
```gdscript
# data/weapon_data.gd
extends EquipmentData
class_name WeaponData

@export var attack_range: float = 0.0 # 0 = ใช้ระยะหมัด
@export_enum("melee", "projectile") var attack_type: String = "melee"
@export var projectile_scene: PackedScene
```
`data/armor_data.gd` = `extends EquipmentData` + `class_name ArmorData` (ยังว่าง ไว้ใส่ของเฉพาะชุดทีหลัง)
- **กติกา:** field ที่ไอเทม*ทุกชนิด*มีได้ → ไว้ในแม่ `EquipmentData` / field ของ*บางกลุ่ม* → ไว้ในลูก
- ใช้ในโค้ด: `var weapon := item as WeaponData` → ถ้าไม่ใช่อาวุธได้ `null` (ไม่ error)
- `.tres` ของอาวุธต้องสร้างจาก `WeaponData` (New Resource → WeaponData) ไม่งั้นไม่มีช่อง attack_range

**ตั้งชื่อ stat:**
- `_bonus` = **บวกเพิ่ม** ค่าเริ่มต้น `0` (`attack_power_bonus`, `defense_bonus`, `max_hp_bonus`)
- `_multiplier` = **คูณ** ค่าเริ่มต้น `1.0` (`attack_speed_multiplier`, `move_speed_multiplier`) — ใน `InventoryData` รวมด้วยการคูณ (`total *= ...`)
- ค่าที่เป็นของอาวุธเองใช้ชื่อตรงๆ ไม่มีคำต่อท้าย (`attack_range`)

**ปัญหาที่เจอ:**
- สร้าง `weapon_data.gd` ตอนแม่ยังมี field ชื่อเดียวกัน → `member already exists in parent` และ Inspector ไม่โชว์ช่องอะไรเลย แม้ลบออกจากแม่แล้ว → **Project → Reload Current Project**
- เปลี่ยนชื่อ/ลบ `@export` แล้ว ค่าเก่าในไฟล์ `.tres` **ไม่ย้ายตามชื่อใหม่** (เช่น `hp = 100` ค้างใน armor_1.tres) → กรอกค่าใหม่แล้วเซฟ บรรทัดเก่าจะหาย หรือแก้ชื่อในไฟล์ด้วย text editor ตรงๆ
- `attack_type = projectile` แต่ไม่ใส่ `projectile_scene` → เลือก**ปล่อยให้ error** (fail-fast) จะได้รู้ทันทีว่าลืมใส่ ไม่เงียบ

### 3.19 ระบบเพศตัวละคร (male / female)
**แนวคิด:** เพศเก็บใน `AppearanceData` / ไอเทมทุกชิ้นมีเฟรม 2 ชุด / ถ้าไม่มีเฟรมผู้หญิง **ใช้ของผู้ชายแทน (fallback)** ไอเทมใหม่เลยทำแค่ `m` ก่อนก็ใช้ได้
```
player_appearance.tres  gender = "male" | "female"
EquipmentData           sprite_frames_male / sprite_frames_female + get_frames(gender)
Player                  body_frames_male / body_frames_female + _refresh_sprites()
```
`appearance_data.gd` เพิ่ม:
```gdscript
@export_enum("male", "female") var gender: String = "male":
	set(value):
		gender = value
		emit_changed()
```
`equipment_data.gd` เพิ่ม:
```gdscript
@export var sprite_frames_male: SpriteFrames
@export var sprite_frames_female: SpriteFrames # ว่างไว้ = ใช้ของ male แทน

func get_frames(gender: String) -> SpriteFrames:
	if gender == "female" and sprite_frames_female:
		return sprite_frames_female
	return sprite_frames_male
```
Player — รวมการตั้งเฟรม**ทุกชั้น**ไว้ที่เดียว:
```gdscript
@export var body_frames_male: SpriteFrames
@export var body_frames_female: SpriteFrames

# ใน _ready()
	appearance.changed.connect(_refresh_sprites)
	_refresh_sprites()

func _on_equipment_changed(slot: String, item: EquipmentData) -> void:
	if slot == "weapon":
		var weapon := item as WeaponData
		_set_attack_range(weapon.attack_range if weapon and weapon.attack_range > 0 else unarmed_range)
	_refresh_sprites()

func _refresh_sprites() -> void:
	animated_sprite.sprite_frames = body_frames_female if appearance.gender == "female" else body_frames_male
	face_sprite.sprite_frames = _frames_of(appearance.face)
	armor_sprite.sprite_frames = _frames_of(inventory.equipped.get("armor"))
	weapon_sprite.sprite_frames = _frames_of(inventory.equipped.get("weapon"))
	_sync_layers()

func _frames_of(item: EquipmentData) -> SpriteFrames:
	return item.get_frames(appearance.gender) if item else null
```
- **ทำไมรวมเป็นฟังก์ชันเดียว:** เปลี่ยนเพศ = ทุกชั้นต้องเปลี่ยนพร้อมกัน ถ้าตั้งเฟรมแยกกันตามที่ต่างๆ (เดิม: ชุด/ดาบตั้งตอนใส่ของ, หน้าตั้งตอน appearance เปลี่ยน) ชุดกับดาบจะค้างเป็นเพศเดิม
- ใส่ของ / ถอดของ / เปลี่ยนเพศ / เปลี่ยนหน้า → ทุกทางเรียก `_refresh_sprites()` ที่เดียว
- เปลี่ยน `sprite_frames` ของ AnimatedSprite2D ระหว่างเล่นได้เลย ท่าที่เล่นอยู่ไม่หลุด ถ้าชื่อท่าในไฟล์ใหม่ตรงกัน

**ขั้นตอนที่ทำ:**
1. จัดโฟลเดอร์รูป: `base_body_m/` → `base_body/m/`, เฟรมไอเทมย้ายลง `<ไอเทม>/1/m/` (`icon.png` อยู่ระดับไอเทม ใช้ร่วมทุกเพศ) — ย้ายผ่าน Godot แล้วแก้ path ค้างในไฟล์ (3.12)
2. สร้าง `f/` จาก `m/` — **ก๊อปแค่ `.png` ไม่เอา `.import`** แล้วให้ Godot import ใหม่ จะได้ uid ใหม่ไม่ซ้ำ (ดู 5.11)
3. เปลี่ยนชื่อ `sprite_frames` → `sprite_frames_male` และไฟล์ `*_frames.tres` → `*_frames_m.tres`
4. SpriteFrames ของตัวที่ฝังอยู่ใน `player.tscn` แยกออกเป็นไฟล์ `body_frames_m.tres` (Inspector → Sprite Frames ▾ → **Save As...**) ถึงจะเอาไปใส่ช่อง export ได้
5. สร้าง `*_frames_f.tres` ให้ชี้รูปใน `f/` แล้วใส่ช่อง `sprite_frames_female` / `body_frames_female`

- ตอนนี้รูปใน `f/` ยังเหมือน `m/` ทุกพิกเซล → แก้สี/วาดใหม่ใน Aseprite ได้เลย ไม่ต้องแก้โค้ด
- ถ้าตั้ง gender = female แต่ช่อง `body_frames_female` ว่าง → **ตัวละครหายทั้งตัว**
- ท่าไหนเพิ่มในตัว (body) ต้องเพิ่มชื่อท่าเดียวกัน + **จำนวนเฟรมเท่ากัน** ในไฟล์ชุด/หน้าด้วย ไม่งั้น layer นั้นหายตอนเล่นท่านั้น (Loop/FPS ของ layer ไม่มีผล เพราะ layer แค่ก๊อปท่า+เฟรมจากตัว)

### 3.20 ไอเทมจำกัดเพศ + แยกชุดชาย/หญิง
`equipment_data.gd`:
```gdscript
@export_enum("any", "male", "female") var gender_lock: String = "any" # ค่าเริ่มต้น any = ลืมตั้งก็ใส่ได้ทุกเพศ

func can_equip(gender: String) -> bool:
	return gender_lock == "any" or gender_lock == gender
```
`inventory_data.gd` — กฎอยู่ที่**ข้อมูล** (วันหน้า server ใช้กฎชุดเดียวกัน):
```gdscript
func toggle_equip(item: EquipmentData, gender: String) -> void:
	if is_equipped(item):
		equipped.erase(item.slot)
		equipment_changed.emit(item.slot, null)
	elif item.can_equip(gender):
		equipped[item.slot] = item
		equipment_changed.emit(item.slot, item)

func unequip_locked(gender: String) -> void:
	for item in equipped.values(): # values() คืนสำเนา → ถอดระหว่างวนได้
		if not item.can_equip(gender):
			toggle_equip(item, gender)
```
- UI: `button.disabled = not item.can_equip(appearance.gender) and not button.button_pressed` (ปุ่มเทา แต่ถ้าใส่อยู่ยังกดถอดได้) + `button.pressed.connect(func(): inventory.toggle_equip(item, appearance.gender))` — **lambda** อ่านเพศล่าสุดตอนกด (`.bind` จะล็อกค่าตอนสร้างปุ่ม)
- Player: `appearance.changed` → `_on_appearance_changed()` = `unequip_locked()` แล้ว `_refresh_sprites()` (เปลี่ยนเพศตอนใส่ของล็อก → ถอดให้เอง)
- InventoryUi ต้องใส่ช่อง **Appearance** ใน `village.tscn`
- `get_frames()` = **fallback** (ไม่มีรูปผู้หญิงก็ใช้รูปผู้ชาย) — เป็นกติกาที่ตั้งใจ ไม่ใช่การดัก error ถ้า `sprite_frames_male` ว่างจริง layer จะหายให้เห็น
- เลือก**แยกเป็น 2 ชิ้น** (`armor_1_m.tres` ล็อก male / `armor_1_f.tres` ล็อก female) แบบเกมขายชุดชาย-หญิงแยก (อีกทางคือชิ้นเดียว `any` แล้วใช้ fallback)

### 3.21 ท่าโจมตีตามอาวุธ + ธนู
`weapon_data.gd`: `@export_enum("attack", "shoot") var attack_animation: String = "attack"` (เมนูเลือก กันพิมพ์ผิด / `@export_enum` ใช้กับ `String`, `int` ได้ ไม่รองรับ `StringName`)
Player:
```gdscript
var attack_anim: String = "attack"
# _attack():  attack_anim = weapon.attack_animation if weapon else "attack"
# _physics_process: animated_sprite.play(attack_anim, ...)
# _on_animation_finished: if animated_sprite.animation == attack_anim: is_attacking = false
```
- ท่า `shoot` ใน body **ปิด Loop** (โค้ดรอ `animation_finished`) — ท่าอื่นที่ไม่รอให้จบ (idle/walk/jump/dash) เปิด Loop ได้
- ธนู `items/weapons/bow/1/1.tres`: Attack Type = projectile, Projectile Scene = `arrow.tscn`, Attack Animation = shoot
- อาวุธมีท่าแค่บางท่า → ท่าที่ไม่มี อาวุธหาย (เช่น ธนูยังไม่มี `shoot`)
- ยังไม่ทำ: ระยะลูกธนูตามอาวุธ (ตอนนี้ใช้ `max_distance` ของ `arrow.tscn` = 300 ทุกคัน)

### 3.22 เตรียมรูปจาก asset (Game Assets)
ขั้นตอน: `Desktop\assets\...\0.png-59.png` → ก๊อปไป `Desktop\Game Assets\...` ตั้งชื่อตามท่า (`idle_0`, `walk_3`) + จด `note.txt` (ท่า = เลขต้นฉบับ) → จัด canvas → ก๊อปเฉพาะ `.png` เข้าเกม
- **Base Body M กับ F เลขเฟรมไม่ตรงกัน:** F มีเฟรมซ้ำเกิน 2 เฟรม → M 0-39 = F เลขเดียวกัน / M 40-57 = F +1 / M 58-59 = F +2 → **เปิดดูรูปทุกครั้ง อย่าใช้เลข M กับ F ตรงๆ** (ท่า shoot ของ F: ตัว 56-57, ชุด 55-56)
- **รูป asset ถูกตัดขอบ (trim)** ขนาดแต่ละเฟรม/แต่ละ layer ไม่เท่ากัน → ต้องจัด canvas ก่อนใช้ (Godot วางจุดกลางรูปทุก layer ตรงกัน)
  - **ชุด (อยู่บนตัว):** วางให้ตรงตัวแล้วใช้ canvas = ตัว + 20 ทุกด้าน
  - **อาวุธ (ยื่นนอกตัว):** ขยาย canvas **Left = Right และ Top = Bottom** (ไม่จำเป็นต้องครบ 4 ด้าน แต่ต้องเท่ากันเป็นคู่) ดูที่แถบล่างของ Aseprite ว่าขนาด = ตัว + เลขคู่
  - **มอนสเตอร์:** ทุกเฟรมใส่ canvas เดียวกัน ให้ตัวอยู่กลาง (ท่าตีที่ลิ้น/แขนยื่นจะไม่ทำให้ตัวกระตุก และ `flip_h` กลับด้านถูกจุด) — มอน 1 = 150x96, มอน 2 = 98x78
- ห้ามเปลี่ยนขนาดไฟล์ตัวละครอีก เพราะชุดทุกชุดอิงขนาดนี้
- หาตำแหน่งวางชุดอัตโนมัติ: เท้าชุดชิดเท้าตัว แล้วเลื่อนหาจุดที่ "เนื้อโผล่น้อยสุด + ชุดล้นตัวน้อยสุด" → ต้องเปิดดูด้วยตาซ้ำเสมอ

### 3.23 มอนสเตอร์ (เดิน / ไล่ / ตี / ตาย) + ผู้เล่นโดนตี
**Collision layer** (Project Settings → Layer Names → 2D Physics): 1 = world, 2 = player, 3 = monster
| | Layer (ฉันเป็นอะไร) | Mask (ฉันชน/ตรวจเจออะไร) |
|---|---|---|
| Player | 2 | 1 |
| Player AttackArea, arrow.tscn | – | 1 + 3 |
| Monster | 3 | 1 → **เดินทะลุผู้เล่นได้** แบบ MapleStory |
| Monster DetectArea / AttackArea | 0 | 2 |
| enemy_orb.tscn (กระสุนมอน) | 0 | 1 + 2 |

`monster.tscn`: CharacterBody2D + AnimatedSprite2D (walk วน / attack, die ไม่วน) + CollisionShape2D (ขอบล่างตรงเท้า) + **DetectArea** (วงกลมระยะมองเห็น) + **AttackArea** (กล่องตรงลิ้น/อาวุธ ตอนหันขวา)
`monster.gd` (สรุป):
- ไม่มีเป้า → `_patrol()` เดินไปมา ±`patrol_distance` จากจุดเกิด ชนกำแพงกลับตัว
- `DetectArea.body_entered` → `target = body` / `body_exited` → เลิกไล่
- มีเป้า → หันหา เดินเข้าหา ถึง `attack_range` แล้วหยุด → ตีเมื่อ cooldown หมด
- ดาเมจเข้าที่ **เฟรมที่กำหนด** (`attack_hit_frame`) ผ่าน `frame_changed` ไม่ใช่ตอนเริ่มท่า
- `attack_box_x = absf(attack_area.position.x)` อ่านจาก scene ตอน `_ready` → มอนตัวใหม่แค่ลากกล่องไปวางใน editor
- ตาย: `die()` → `is_dead`, `collision_layer = 0` (ตีซ้ำไม่ได้), ปิด Area ด้วย `set_deferred("monitoring", false)` (ปิดทันทีระหว่าง physics ไม่ได้), เล่น `die` → `animation_finished` ค่อย `queue_free()`

ผู้เล่นโดนตี (`player.gd`):
```gdscript
func take_damage(amount: int) -> void:
	var damage := maxi(1, amount - (stats.defense + inventory.get_defense_bonus()))
	stats.hp = maxi(stats.hp - damage, 0)
```
- **HUD อัปเดตสด:** `StatsData.hp` มี setter เรียก `emit_changed()` → HUD `stats.changed.connect(_refresh)`
- ทั้งผู้เล่นและมอนตีกันด้วยวิธีเดียว: **กล่องโจมตี + `take_damage()`** (วันหน้ายกเป็นระบบสกิลกลาง)
- Stats มอนใช้คลาส `StatsData` เดียวกับผู้เล่น แต่คนละไฟล์ + `duplicate()` ต่อตัว (ช่อง level/exp/mp มีติดมาแต่ไม่ใช้) วันหน้ามีช่องเฉพาะมอน (exp_reward) → `MonsterStats extends StatsData`
- ระวังระยะมองเห็นตอนวางมอน: ที่ x = -300 มอนเดินมาเห็นผู้เล่นตั้งแต่จุดเกิด → ย้ายไป -500

### 3.24 มอนตีไกล + Inherited Scene
`monster.gd`: `@export var projectile_scene: PackedScene` — **ใส่ = ยิง / ว่าง = ตีประชิด** (แบบเดียวกับอาวุธผู้เล่น)
```gdscript
func _shoot() -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	projectile.direction = direction
	projectile.damage = stats.attack_power   # ดาเมจมาจากมอนที่ยิง ไม่ใช่ตัวกระสุน
	projectile.shooter = self
	projectile.position = position + attack_area.position   # ยิงออกจากตำแหน่ง AttackArea
	get_parent().add_child(projectile)
```
- **มอนตัวใหม่ = คลิกขวา `monster.tscn` → New Inherited Scene** แล้วเปลี่ยนแค่ค่าที่ต่าง (frames, stats, ระยะ, cooldown, ขนาดกล่อง) → แก้ `monster.gd` ที่เดียวมีผลทุกตัว
- **ไม่แยก `monster.gd` ตัวละไฟล์** (แก้บั๊กต้องแก้ทุกไฟล์) — แยกเฉพาะมอนพิเศษจริง (บอส) ด้วย `extends "res://entities/monsters/monster.gd"`
- **กระสุน:** ใช้ `projectile.gd` ตัวเดียวทุกลูก ต่างกันที่ scene (รูป/ความเร็ว/ระยะ/mask) → กระสุนแบบใหม่ = Inherited Scene จาก `enemy_orb.tscn` / มอนหลายตัวใช้กระสุนเดียวกันได้ (ดาเมจต่างตาม `attack_power` ของมอน)
- `attack_range` ของมอนต้อง **น้อยกว่า** `max_distance` ของกระสุน ไม่งั้นยิงไม่ถึง
- มอน 2 (ผี): ยิงเฟรมที่ 2 (มือยกสูงสุด) ระยะยืนยิง 180, มองเห็น 260, cooldown 2 วิ

### 3.25 แผนระบบสกิล (ออกแบบแล้ว ยังไม่ได้ทำ)
**สิ่งที่ต้องการ:**
1. สกิลหลายประเภท: โจมตี / บัพ / อื่นๆ เช่น เสกมอน
2. ใช้สกิลโดยเอาสกิลใส่ช่องล่างจอ กดเลข 1 2 3 4
3. แต่ละอาชีพมีสกิลต่างกัน แต่ตัวสกิลเป็นของกลาง มอนใช้สกิลเดียวกันได้
4. สกิลมีเลเวล แต่ละสกิลโตไม่เท่ากัน (ดาเมจ/MP เพิ่มตามเลเวล, บัพเพิ่ม defense มากขึ้นแต่ลดพลังโจมตีมากขึ้น ฯลฯ)
5. มีทั้ง Active (กดใช้) และ Passive (ติดตัว)
6. บัพไม่ได้มีแค่เพิ่ม/ลด stat เช่น เกราะบางอันใส่แล้วทำดาเมจรอบตัวเรื่อยๆ

**โครงสร้าง:**
```
SkillData (แม่)          id, ชื่อ, ไอคอน, คำอธิบาย, เลเวลสูงสุด
├─ ActiveSkill           + cooldown, MP, ท่า, func use(ผู้ใช้, เลเวล)   ← ใส่ช่อง 1-4 ได้
│  ├─ AttackSkill        ดาเมจกี่เท่า, ประชิด/ยิง, ระยะ
│  ├─ BuffSkill          ระยะเวลา + รายการ Effect (ใส่ให้ตัวเอง)
│  └─ SummonSkill        เสกมอนตัวไหน กี่ตัว
└─ PassiveSkill          รายการ Effect แบบไม่มีวันหมด                   ← ใส่ช่องไม่ได้

EffectData (ชิ้นส่วน "ผลที่ติดตัว" ประกอบกันได้)
├─ StatEffect            เพิ่ม/ลด stat (ค่าติดลบ = ลด)
├─ AuraEffect            ดาเมจรอบตัวทุก X วิ รัศมี Y (มี Area2D ของตัวเอง)
├─ RegenEffect           ฟื้น HP/MP ทุก X วิ
└─ (อนาคต) PoisonEffect ฯลฯ — สกิลโจมตีใส่ Effect ให้ "เป้าหมาย" ได้ด้วย ระบบเดียวกัน

JobData                  อาชีพ = รายการสกิลที่เรียนได้ (ตัวสกิลเป็นไฟล์กลาง)
HotbarData               ช่อง 1-4 ใส่ ActiveSkill อะไร (แบบเดียวกับ InventoryData)
```
- กดใช้: โค้ดเรียกแค่ `skill.use(ผู้ใช้, เลเวล)` ไม่ต้องรู้ประเภท / ผู้เล่น = กดปุ่ม + เสีย MP, มอน = AI เลือก (cooldown หมด / ใกล้ใช้ประชิด ไกลใช้ยิง)
- Effect ที่ทำงานอยู่ = node ลูกของตัวละคร มีตัวจับเวลาของตัวเอง หมดเวลาลบตัวเอง (Buff = มีเวลา, Passive = ไม่มี)
- ค่าตามเลเวลเก็บเป็นรายการ เช่น `damage_multiplier: Array[float] = [1.5, 1.8, 2.2, 2.8]` / `mp_cost: Array[int] = [5, 8, 12, 18]`
- ตัวอย่างบัพ "เกราะเพลิง" Lv3: 15 วิ, StatEffect defense +20, StatEffect attack -3, AuraEffect ดาเมจ 12 ทุก 1 วิ รัศมี 60
- ต้องรื้อก่อนทำบัพ: **ระบบคิด stat กลาง** = stat พื้นฐาน + ชุด + Effect ที่ทำงานอยู่ (ตอนนี้คิดแยกกันหลายที่ เช่น `stats.defense + inventory.get_defense_bonus()`)

**กฎที่ต้องตัดสินใจตั้งแต่แรก (แก้ทีหลังยาก):**
1. **ไฟล์สกิลเก็บแค่ค่าที่ไม่เปลี่ยน** — cooldown ที่เหลือ, เลเวลสกิล, บัพที่ทำงานอยู่ เก็บที่ตัวผู้ใช้ (ไฟล์ .tres ใช้ร่วมกัน ถ้าเก็บในไฟล์ ทุกคนติด cooldown พร้อมกัน = บั๊กแบบ Dummy เลือดลดพร้อมกัน)
2. **สกิลทุกตัวมี `id`** — save/load อ้างด้วย id ไม่ใช่ path ไฟล์ (เปลี่ยนชื่อไฟล์แล้วเซฟเก่าไม่พัง)
3. **บัพตัวเดิมกดซ้ำ = ต่อเวลา ไม่ซ้อน**

**ข้อเสีย / ที่ต้องระวัง:**
- คลาสเยอะ ไล่บั๊กยาก → สร้างคลาสเฉพาะตอนมีสกิลจริงมาใช้ ไม่สร้างเผื่อ
- รายการค่าตามเลเวลใส่ไม่ครบ = พัง / ปรับสมดุลเหนื่อย → ฟังก์ชันกลางดึงค่า (รายการสั้นใช้ตัวสุดท้าย) หรือสูตร "ค่าเริ่ม + เพิ่มต่อเลเวล"
- รื้อระบบ stat กระทบผู้เล่น/มอน/ชุด → ทดสอบการโจมตีทั้ง 4 แบบ + defense ของชุดทุกครั้ง
- สกิลกลไกพิเศษต้องเขียนคลาสใหม่ทีละแบบ (ไม่ใช่แค่ใส่ข้อมูล): พุ่งตัวตี, combo หลายครั้ง, ลำแสงค้าง/ชาร์จ, knockback, hitstop, อมตะหลังโดนตี
- ผู้เล่นเสกมอนช่วยสู้ ต้องมี **ระบบฝ่าย (team)** ก่อน (กระทบโค้ดตีทุกจุด ตอนนี้ layer แบ่งแค่ผู้เล่นกับมอน) → ถ้าจะมีแน่ ทำระบบฝ่ายก่อนมีสกิลเยอะ
- ออนไลน์: ตรรกะสกิลต้องย้ายไป server + sync บัพ/ออร่า/มอนที่เสก (สกิลแบบข้อมูลล้วนช่วยให้ย้ายง่ายขึ้น)
- AI มอนแบบกฎง่ายทำได้ทันที / AI ฉลาด (บอสหลายเฟส) เขียนแยกเฉพาะตัว
- มีแค่ท่า `attack` / `shoot` → สกิลช่วงแรกหน้าตาเหมือนกัน จนกว่าจะมีรูป

**ลำดับทำ:**
| ช่วง | งาน | ยาก |
|---|---|---|
| 1 | SkillData + ActiveSkill + AttackSkill + เลเวลสกิล + ช่อง 1-4 (ใส่สกิลผ่าน Inspector) + แถบ MP/MP ฟื้น + `take_damage(amount, attacker)` (มอนโดนตีแล้วไล่คนตีมาด้วย) + ปุ่ม `skill_1`-`skill_4` | กลาง |
| 2 | ระบบคิด stat กลาง + EffectData (Stat / Aura) + BuffSkill + PassiveSkill | กลาง |
| 3 | SummonSkill (มอนเสกลูกน้องก่อน) | ง่าย |
| 4 | EXP / เลเวล → แต้มสกิล → อัปเลเวลสกิล (ระหว่างนี้ตั้งเลเวลสกิลใน Inspector) | กลาง |
| 5 | JobData + หน้าต่างรายการสกิล ลากใส่ช่องได้ | กลาง-ยาก |
| 6 | ระบบฝ่าย → ผู้เล่นเสกมอนช่วยสู้ | ยาก |

---

## 4. Input Actions ที่ใช้

| Action | ที่มา | ใช้ทำอะไร |
|---|---|---|
| `move_left`, `move_right` | **ต้องสร้างเอง** (ลูกศรซ้าย/ขวา, Physical Keycode) | เดินซ้าย-ขวา |
| `jump` | **ต้องสร้างเอง** (Space) | กระโดด |
| `dash` | **ต้องสร้างเอง** ผ่าน Project Settings → Input Map | พุ่ง (ผูกปุ่ม Shift) |
| `attack` | **ต้องสร้างเอง** ผ่าน Project Settings → Input Map | โจมตี (ผูกปุ่ม Z) |
| `inventory` | **ต้องสร้างเอง** ผ่าน Project Settings → Input Map | เปิด/ปิดกระเป๋า (ผูกปุ่ม I) |

**ห้ามใช้ `ui_left` / `ui_right` / `ui_accept` กับการควบคุมตัวละคร** — เป็น action ที่ Godot ใช้เลื่อน/กดปุ่มในเมนู UI ใช้ร่วมกันแล้วชนกัน (ดู 3.14 ข้อ 2)
**Physical Keycode** = ผูกตามตำแหน่งปุ่มบนคีย์บอร์ด ไม่ใช่ตัวอักษร เปิดภาษาไทยค้างไว้ก็ยังกดได้

---

## 5. ปัญหาที่เจอจริงระหว่างทาง + วิธีแก้ (สำคัญมาก อ่านซ้ำได้เวลาเจอปัญหาเดิม)

### 5.1 สร้าง Scene ผิด Root Type
เผลอเลือก Root Type เป็น `Node` เฉยๆ แทน `CharacterBody2D` → แก้โดยคลิกขวา node → **Change Type...** โดยไม่ต้องสร้างใหม่ทั้งหมด (ลูกๆ ยังอยู่ครบ)

### 5.2 Change Type ผิด node
คลิกขวาผิดตัว (เปลี่ยน root แทนลูก) — เช็คด้วย `scene_get_hierarchy` หรือดูไอคอนหน้าชื่อ node ในพาแนล Scene ให้ตรงกับชนิดที่ตั้งใจ

### 5.3 ColorRect ไม่มี Size/Position ตรงๆ
เพราะเป็น **Control** node ไม่ใช่ Node2D — ค่าตำแหน่ง/ขนาดซ่อนอยู่ในหมวด **Layout** ไม่ใช่ Transform ตรงๆ → ควรเลี่ยงใช้ ColorRect ในฉากโลกเกม ใช้ **Polygon2D** แทน

### 5.4 ไฟล์ `.tscn` ตัวพิมพ์ใหญ่-เล็กไม่ตรงกัน (Case Mismatch)
เผลอเซฟเป็น `Village.tscn` (V ใหญ่) แล้ว rename เป็น `village.tscn` แต่มีการอ้างอิงเก่าค้าง (tab, cache) เรียก path ตัวใหญ่อยู่ → เกิด warning "Case mismatch" (จะพังจริงถ้า export ไปแพลตฟอร์มที่สนตัวพิมพ์เล็ก-ใหญ่อย่าง Linux) **บทเรียน:** ตั้งชื่อไฟล์ตัวเล็กตั้งแต่แรกให้ถูกตามหลัก snake_case จะได้ไม่ต้อง rename ทีหลัง

### 5.5 Scene reload ทำค่าที่ยังไม่เซฟหายไป
แก้ Polygon ผ่าน MCP tool แต่ยังไม่ทัน `scene_save()` ก็มีการ reload scene จากดิสก์ (เช่นจาก case-mismatch ด้านบน) → ค่าที่แก้ไปหายกลับเป็นค่าเดิมบนดิสก์ **บทเรียน:** แก้เสร็จให้ **เซฟทันที** (Ctrl+S) ก่อนสลับ/ทำอย่างอื่นต่อ

### 5.6 Polygon2D หลุดตำแหน่งจากการคลิกใน viewport ผิดจังหวะ
ตอนพยายามคลิกวาดจุดใน Polygon editor แต่คลิกโดนตัว node เอง ทำให้ **Position ของ Polygon2D เปลี่ยนไปทั้งก้อน** (จาก 0,0 เป็น 373,284) — ภาพ (Polygon2D) กับจุดชน (CollisionShape2D) เลยไม่ตรงกัน ทั้งที่ทั้งคู่เป็นลูกของ node เดียวกัน **บทเรียน:** Polygon2D (ภาพ) กับ CollisionShape2D (ฟิสิกส์) เป็นคนละ node กันโดยสิ้นเชิง ไม่ผูกกันอัตโนมัติ ถ้าย้ายอันหนึ่งอีกอันไม่ขยับตาม ต้องเช็ค `position` ของทั้งคู่แยกกันเวลามีปัญหา

**เครื่องมือช่วยแก้ที่แม่นยำกว่าคลิกด้วยมือ:** ใส่ค่าตัวเลขตรงๆ ผ่าน Inspector (หรือ MCP `node_set_property`) แทนการคลิกวาดในวิว ลดโอกาสพลาด

### 5.7 ไม่มี Camera2D ทำให้มองไม่เห็นอะไร
ไม่มีกล้องในฉาก → Godot render โดยเอา world (0,0) ไปไว้มุมบนซ้ายจอ แทนกึ่งกลาง/ตามตัวละคร ตัวละครที่อยู่พิกัดติดลบ (เช่น x=-200) เลยหลุดจอไปเลย **บทเรียน:** ทุกฉากที่มีตัวละครเดินได้ ต้องมี `Camera2D` เป็นลูกของตัวละครตั้งแต่แรก

### 5.8 @export var ถูก override เป็นค่าผิดใน instance โดยไม่รู้ตัว
`speed` ของ Player ถูกเซ็ตเป็น `0` (และ `jump_velocity` เป็น `-100`) ที่ระดับ **instance ใน `village.tscn`** ทั้งที่ต้นฉบับ `player.tscn` ตั้งไว้ถูกต้อง (200 / -400) — เกิดจากคลิกพลาดใน Inspector ก่อนหน้าโดยไม่รู้ตัว อาการที่เจอ: animation เดินเล่นถูกต้อง (เพราะ `direction` คำนวณถูก) แต่ตัวละครไม่ขยับเลย (เพราะ `velocity.x = direction * speed` = `direction * 0`) **บทเรียน:** ตัวแปร `@export` แก้ผ่าน Inspector ของ **instance เฉพาะที่** ได้ แยกจากค่า default ในไฟล์ scene ต้นฉบับ ถ้าเจออาการ "logic ถูกแต่ผลลัพธ์ผิด" ให้สงสัยค่าที่ถูก override ก่อน — เช็คด้วย `node_get_properties` หรือดูใน Inspector ว่ามีไอคอน "reset" (ลูกศรวน) ขึ้นข้างๆ property ไหม (แปลว่าค่านั้นถูกแก้ต่างจาก default แล้ว)

### 5.9 CollisionShape2D ขนาดไม่ตรงกับรูปจริง
ตั้ง CollisionShape2D เป็น `20x20` ไว้ตั้งแต่ตอนยังไม่มี asset จริง พอใส่รูปจริง (`36x77` พิกเซล) แล้วลืมปรับตาม ทำให้กล่องชนเล็กกว่าตัวละครมาก **บทเรียน:** พอใส่ asset จริงเข้าไปแทน placeholder ทุกครั้ง ให้กลับไปเช็ค/ปรับขนาด CollisionShape2D ให้เข้ากับขนาดจริงเสมอ (เช็คขนาดไฟล์รูปจริงได้ง่ายๆ ด้วยการเปิดดู)

### 5.10 ไฟล์ `.uid`
Godot สร้างไฟล์ `.uid` คู่กับทุก `.gd` อัตโนมัติ (ตั้งแต่ Godot 4.3+) เก็บรหัสอ้างอิงไม่ให้ path เปลี่ยนแล้วพัง **ห้ามเอา `uid=` ของสคริปต์เก่าที่ลบไปแล้วไปแปะใน `.tscn` ใหม่** เพราะ Godot จะโหลดสคริปต์ผิดแบบเงียบๆ ไม่มี error ชัดเจน

### 5.11 ก๊อปไฟล์แล้ว uid ซ้ำ → โหลดไฟล์ผิดแบบเงียบๆ
- **ก๊อปรูป:** ห้ามก๊อปใน Windows Explorer พร้อมไฟล์ `.import` (uid ติดไปด้วย = 2 รูปมี uid เดียวกัน) → ก๊อป**แค่ `.png`** แล้วให้ Godot import ใหม่ หรือใช้คลิกขวา → **Duplicate...** ใน Godot
- **ก๊อป `.tres` แล้วแก้แค่ path ไม่พอ:** Godot เชื่อ `uid=` ก่อน `path=` → ถ้าก๊อป `armor_1_frames_m.tres` แล้วเปลี่ยน `/m/` เป็น `/f/` อย่างเดียว มันจะ**ยังโหลดรูปใน `m/`** อยู่ ต้องเปลี่ยน uid ให้เป็นของรูปใหม่ด้วย (ดูได้จากบรรทัด `uid=` ในไฟล์ `.import` ของรูป) หรือลบ `uid="..."` ทิ้ง
- ลบ `uid="..."` บนบรรทัดแรก (`[gd_resource ...]`) ของไฟล์ที่ก๊อปมาด้วย ไม่งั้น 2 ไฟล์มี uid ตัวเองซ้ำกัน

### 5.12 แก้ไฟล์ข้างนอก Godot แล้ว editor ยังเห็นของเก่า
เปลี่ยนชื่อตัวแปรใน `.gd` ด้วย text editor แล้ว Inspector ยังโชว์ชื่อเก่า → **Project → Reload Current Project** ก่อนแก้อะไรต่อ ถ้ากดเซฟไอเทมตอนที่ Inspector ยังเป็นชื่อเก่า ชื่อเก่าจะถูกเขียนกลับลงไฟล์

### 5.13 ขยาย canvas ดาบแค่ด้านบน → ดาบลอยต่ำกว่ามือ
ตัว 56x74 แต่ไฟล์ดาบ 96x94 (ซ้าย 20 ขวา 20 **บน 20 ล่าง 0**) → จุดกลางไฟล์ดาบเลื่อนขึ้น 10 (ครึ่งของ 20) → Godot วางจุดกลางตรงกัน ดาบเลยต่ำไป 10 px
**กติกา:** Left = Right, Top = Bottom เสมอ ถึงดาบไม่ยื่นลงล่างก็ต้องเติมล่างให้เท่าบน / ตอนทำชุดสมัยก่อนขยายแค่บนแล้วยังตรง เพราะตอนนั้น**ไฟล์ตัวถูกเซฟขยายไปด้วย** (2 ไฟล์ขนาดเท่ากัน = จุดกลางตรงกันเอง) — หลักจริงคือ "ขนาดเท่ากัน" หรือ "ขยายเท่ากันเป็นคู่"

### 5.14 เปลี่ยนขนาดไฟล์ตัวละครแล้วชุดพังหมด
ชุดทุกชุดทำมาตามขนาดไฟล์ตัว ถ้าขยาย canvas ตัว (เพื่อเผื่อที่ให้อาวุธ) แล้วเซฟ จุดกลางตัวเลื่อน ชุดทั้งหมดไม่ตรง → **ห้ามเซฟไฟล์ตัว** ให้ขยายเฉพาะไฟล์อาวุธ (ใน Aseprite: ขยาย → วาดใน layer ใหม่ → ซ่อน layer ตัว → Export As → ปิดแบบ Don't Save) / ถ้าเผลอเซฟ ดึงคืนจาก git ได้

### 5.15 Godot ย้ายไฟล์ไม่ได้: "Move requires dependency path rewrites"
ไฟล์ที่ถูกอ้างถึงด้วย `path=` อย่างเดียว (ไม่มี `uid=` เช่นไฟล์ที่สร้างด้วยมือ) → Godot ย้ายแล้วแก้ path ในไฟล์ที่อ้างถึงให้ไม่ได้ → แก้ path ในไฟล์ที่อ้างถึงเองก่อน แล้วค่อยย้าย / พอ Godot เซฟไฟล์นั้นครั้งถัดไปจะเติม uid ให้เอง

### 5.16 มอนตายแล้วหายทันที ไม่เล่นท่าตาย
`take_damage()` เรียก `queue_free()` ตอนเลือดหมด → ถูกลบก่อนท่า `die` ได้แสดงสักเฟรม → เปลี่ยนเป็น `die()` ที่เล่นท่าก่อน แล้ว `queue_free()` ใน `animation_finished` (ดู 3.23)

### 5.17 เครื่องมือแก้ไฟล์ติด "classifier gave no verdict" ใน Auto mode
ตัวตรวจความปลอดภัยของโหมด Auto ล่ม → แก้ไฟล์ไม่ได้เลยแม้บรรทัดเดียว → กด Shift+Tab เปลี่ยนเป็น **Edit automatically** หรือ **Manual** ชั่วคราว

---

## 6. เช็คลิสต์ก่อนบอกว่า "เสร็จแล้ว" (ทำทุกครั้งหลังแก้ `.tscn`/`.gd`)
1. `scene_open(force_reload=true)` เช็ค error ที่โหลดใหม่
2. เช็ค `logs_read(source="editor")` และ `source="game"` ว่ามี error/warning ไหม
3. รันเกมจริงทดสอบ (`project_run`) ไม่ใช่แค่ดูโค้ดเฉยๆ
4. ถ้าเป็น property ของ instance ที่แก้ผ่าน Inspector ให้เช็คว่าไม่ได้ไปสร้าง override ผิดที่ (ดูข้อ 5.8)

---

## 7. Roadmap ที่เหลือ (อ้างอิงจาก `rpg-online-plan.md`)

- [x] Movement + collision (เดิน, กระโดด, พุ่ง, ชนกำแพง)
- [x] ระบบ Stats (HP/MP/EXP/Level) — `StatsData` resource + HUD แสดงหลอด HP อัปเดตสดแล้ว (3.23)
- [x] ระบบต่อสู้พื้นฐาน — โจมตี Dummy ด้วย Area2D hitbox, ลด HP, ตายแล้ว `queue_free()`, มี animation attack จริง
- [x] ระบบ Equipment (ชุดเกราะ + อาวุธ) — `EquipmentData` resource, layered sprite หลายเลเยอร์ sync ด้วย signal, ชุดครบทุกท่า
- [ ] ดาบติดมือ — ทำแล้วเฉพาะท่า `idle` (มีเฟรมตัวอย่างครบทุกท่าที่ `Desktop\assets\sword_frames\`)
- [x] UI Inventory — กด I เปิด, กดไอเทม = ใส่, กดซ้ำ = ถอด
- [x] หน้าตาตัวละคร (Face) — `AppearanceData` + ไอเทมหน้า (ทำแล้วเฉพาะ `idle_0`)
- [x] ทบทวนโปรเจกต์ 4 ข้อ (export_enum, input action ของเกม, duplicate stats มอนสเตอร์, ดาเมจไม่เขียนทับ stats)
- [x] ระยะโจมตีตามอาวุธ + ท่าโจมตีจบด้วย `animation_finished`
- [x] อาวุธตีไกล (ระบบกระสุน `Projectile`) — ยังไม่มีรูปธนู/ลูกธนู
- [x] แยกคลาส `WeaponData` / `ArmorData` + ตั้งชื่อ `_bonus` / `_multiplier` (ดู 3.18)
- [x] ระบบเพศ male/female + fallback เป็นของผู้ชาย (ดู 3.19) — รูปใน `f/` ยังเป็นสำเนาของ `m/`
- [x] รูปผู้หญิงจริง: ตัว (Base Body F) + ชุด Blood Crow F — หน้ายังเป็นสำเนา
- [x] ไอเทมจำกัดเพศ (`gender_lock`) + ชุด armor_1_m / armor_1_f (3.20)
- [x] ท่าโจมตีตามอาวุธ (`attack_animation`, ท่า `shoot`) + ธนู bow_1 (3.21)
- [x] มอนสเตอร์: เดินไปมา / เห็นแล้วไล่ / ตี / ท่าตาย + ผู้เล่นโดนตี (defense) (3.23)
- [x] มอนตีไกล (`projectile_scene`) + Inherited Scene (3.24)
- [ ] มอนโดนตีแล้วไล่คนตี (`take_damage(amount, attacker)`)
- [ ] EXP ตอนฆ่ามอน + เลเวลอัป / มอนคิด defense
- [ ] ผู้เล่นตาย → เกิดใหม่ / มอนเกิดใหม่ (MonsterSpawner)
- [ ] ระยะลูกธนูตามอาวุธ (`attack_range` → `max_distance`) / รูปลูกธนู + รูปกระสุนมอน
- [ ] ดาบ/ธนูครบทุกท่า (ตอนนี้มีแค่ idle + attack บางเฟรม)
- [ ] ระบบสกิล — ออกแบบแล้ว แผน 6 ช่วง ดู 3.25 (ช่วง 1-3 ทำได้เลย, ช่วง 4 ขึ้นไปต้องมี EXP ก่อน)
- [ ] main scene / หลายแผนที่ — ทำตอนมีแผนที่ที่ 2
- [ ] หมวก + ตาราง `slot_sprites` (ดู 3.17)
- [ ] Item pickup (เก็บของจากพื้น) / ไอเทมใช้แล้วหมด (ยา)
- [ ] Skill system (cooldown, mana cost, effect)
- [ ] Save/Load ตัวละคร (local ก่อน)
- [ ] ค่อยไปแตะ network/multiplayer (Phase 3-4)
