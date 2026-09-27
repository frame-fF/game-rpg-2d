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
├── equipment_data.gd
└── inventory_data.gd
items/                         ← ข้อมูลไอเทมจริง (.tres) = ตัวไอเทม + SpriteFrames ของมัน
├── armor/   armor_1.tres, armor_1_frames.tres
└── weapons/ weapon_1.tres, weapon_1_frames.tres
entities/player/
├── player.tscn, player.gd
├── player_stats.tres, player_inventory.tres
└── sprites/
    ├── base_body_m/           ← เฟรมตัว (idle_0, walk_3, ...)
    ├── armor/1/               ← เฟรมชุด + icon.png
    └── weapons/1/             ← เฟรมดาบ + icon.png
entities/dummy/                ← dummy.tscn, dummy.gd, dummy_stats.tres
ui/hud/, ui/inventory/
levels/village.tscn            ← ด่านทดสอบ
```
**กติกาตั้งชื่อ:**
- ไอเทม 1 ชิ้น = 1 โฟลเดอร์รูป (เฟรมทุกท่า + `icon.png`) + 2 ไฟล์ใน `items/` (`<ประเภท>_<เลข>.tres` + `<ประเภท>_<เลข>_frames.tres`)
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
@export var slot: String # "weapon" หรือ "armor"
@export var attack_bonus: int = 0
@export var sprite_frames: SpriteFrames # เฉพาะ armor ใช้
```
ไฟล์ `.tres` จริง (ตัวข้อมูล ไม่ใช่แม่แบบ) เก็บที่ **`items/`** แยกจาก `data/` (แม่แบบสคริปต์) ส่วนไฟล์รูปอยู่ `entities/player/sprites/armor/<เลข>/`, `.../weapons/<เลข>/` (ดูโครงสร้างที่ 3.1)

อาวุธก็มี `sprite_frames` ได้เหมือนชุด (ถ้ามีเฟรมดาบในมือ) — ไม่ต้องแยก field

**Layered Sprite (ซ้อนหลายเลเยอร์บน Body):**
```
Player (CharacterBody2D)
├── AnimatedSprite2D   ← Body (ผู้คุมเฟรม)
├── ArmorSprite        ← ชุด (ลำดับในลิสต์ = ลำดับการวาด ตัวล่างวาดทับตัวบน)
├── WeaponSprite       ← ดาบ วาดทับชุด
├── CollisionShape2D
├── Camera2D
└── AttackArea
```
- ทุกเลเยอร์อยู่ตำแหน่ง **`(0, 0)`** ใช้ **Centered = true** (ค่า default) — ไม่ต้องมี offset ในโค้ด เพราะรูปถูกจัดให้กรอบตรงกับรูปตัวมาตั้งแต่ใน Aseprite
- **node เลเยอร์ต้องว่างใน scene** (ไม่ตั้ง Sprite Frames ไว้ล่วงหน้า) — รูปจะมาจาก `EquipmentData` ตอนกดใส่ ถ้าตั้งค้างไว้ จะโชว์ภาพนิ่งทั้งที่ยังไม่ได้ใส่ของ (ขึ้น ⚠️ "no SpriteFrames" ในเอดิเตอร์เป็นเรื่องปกติ)
- ชื่อท่าใน SpriteFrames ของเลเยอร์ต้องตรงกับ Body (`idle`, `walk`, ...) ถ้าเลเยอร์ไหน**ยังไม่มีท่านั้น** โค้ดจะซ่อนเลเยอร์นั้นแทนที่จะขึ้น error (ทำเฟรมเพิ่มทีละท่าได้)

**โค้ด sync ทุกเลเยอร์ (แบบถูกหลักการ):**
```gdscript
@onready var armor_sprite: AnimatedSprite2D = $ArmorSprite
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite

func _ready() -> void:
	animated_sprite.frame_changed.connect(_sync_layers)
	animated_sprite.animation_changed.connect(_sync_layers)
	...

func equip_weapon(item: EquipmentData) -> void:
	equipped_weapon = item
	stats.attack_power = base_attack_power + item.attack_bonus
	weapon_sprite.sprite_frames = item.sprite_frames
	_sync_layers()

func equip_armor(item: EquipmentData) -> void:
	equipped_armor = item
	armor_sprite.sprite_frames = item.sprite_frames
	_sync_layers()

func _sync_layers() -> void:
	for layer in [armor_sprite, weapon_sprite]:
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
และใน `_physics_process`: `armor_sprite.flip_h` / `weapon_sprite.flip_h = facing_direction < 0` คู่กับของตัว
- **หลักการ:** ตัว (Body) เป็นเจ้าของเฟรมคนเดียว (single source of truth) เลเยอร์อื่นแค่ลอกตาม และใช้ **signal** (ยิงทันทีตอนตัวเปลี่ยนเฟรม) แทนการเช็คทุกเฟรม → ตรงกันเป๊ะ ไม่มีช่องว่างให้กระพริบ
- วันหน้าเพิ่มผม/ตา: เพิ่ม AnimatedSprite2D อีก node แล้วเพิ่มชื่อเข้าไปใน `[armor_sprite, weapon_sprite]`

**ดาบติดมือ:** asset ที่มีเป็นแค่ไอคอนนิ่ง (`Weapons.png` ตาราง 31x31 ช่องละ 38px) ไม่มีเฟรมตามท่า → ทำเองใน Aseprite: วางไอคอนบนเลเยอร์ใหม่เหนือรูปตัว ขยับ/หมุนให้อยู่ในมือทีละเฟรม แล้ว export แบบเดียวกับชุด
- หมุนใน Aseprite: ตอนภาพยังลอยอยู่ พิมพ์องศาในช่อง `R:` หรือลากจากนอกมุมกรอบ, พลิก Shift+H / Shift+V
- เปลี่ยนโหมดหมุนจาก `Fast Rotation` เป็น **`RotSprite`** ก่อนหมุน ไม่งั้นขอบภาพ pixel art แตกหยัก
- หาช่องไอคอนในตารางใหญ่: เรนเดอร์ช่องพร้อมเลข `แถว,คอลัมน์` กำกับแล้วมองหาด้วยตา (การเทียบภาพอัตโนมัติพลาดง่ายถ้าภาพอ้างอิงถูกขยาย/ครอปต่างกัน)

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

### 3.11 UI Inventory (กด I เปิดกระเป๋า กดไอเทมเพื่อใส่)

**การออกแบบ:** UI กับ Player ไม่รู้จักกันตรงๆ คุยกันผ่าน Resource กระเป๋าไฟล์เดียวกัน (แบบเดียวกับ HUD ↔ StatsData)
```
InventoryData (player_inventory.tres) ← รายการไอเทม + signal "ขอใส่ชิ้นนี้"
   ↑ InventoryUI อ่านรายการ → สร้างปุ่ม → กดแล้วเรียก request_equip(item)
   ↑ Player ฟัง equip_requested → equip(item) แยกตาม slot
```
ลบ UI ทิ้ง Player ยังทำงานได้ปกติ

`data/inventory_data.gd`:
```gdscript
extends Resource
class_name InventoryData

signal equip_requested(item: EquipmentData)

@export var items: Array[EquipmentData] = []

func request_equip(item: EquipmentData) -> void:
	equip_requested.emit(item)
```

Player: `@export var inventory: InventoryData` + ใน `_ready()` `inventory.equip_requested.connect(equip)` +
```gdscript
func equip(item: EquipmentData) -> void:
	if item.slot == "weapon":
		equip_weapon(item)
	elif item.slot == "armor":
		equip_armor(item)
```

`ui/inventory/inventory_ui.tscn`: `InventoryUI (CanvasLayer) > Panel (PanelContainer, %) > Grid (GridContainer, columns 4, %)`
```gdscript
extends CanvasLayer

@export var inventory: InventoryData
@onready var panel: PanelContainer = %Panel
@onready var grid: GridContainer = %Grid

func _ready() -> void:
	panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		panel.visible = not panel.visible
		if panel.visible:
			_refresh()

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	for item in inventory.items:
		var button := Button.new()
		button.text = item.item_name
		button.icon = item.icon
		button.pressed.connect(inventory.request_equip.bind(item))
		grid.add_child(button)
```
- Instance เข้า `village.tscn` แล้วผูก Inventory เป็น `.tres` **ไฟล์เดียวกับที่ผูกใน Player**
- Input Action `inventory` = ปุ่ม I
- **concept ใหม่:** `%Name` (Unique Name — คลิกขวา node → Access as Unique Name) อ้างถึง node ได้แม้ย้ายตำแหน่งในโครง, `Button.new()` สร้างปุ่มด้วยโค้ดเมื่อจำนวนไม่คงที่, `Callable.bind(ค่า)` ผูกค่าติดไปกับฟังก์ชันล่วงหน้า
- ตั้ง `starting_armor` ไว้ด้วยจะทดสอบไม่เห็นผล (ใส่อยู่แล้ว) — เคลียร์ออกก่อนทดสอบปุ่ม
- ยังไม่ทำ: ถอดของ, ลากวางย้ายช่อง, จำกัดช่อง

**ปัญหาที่เจอ + บทเรียน:**
- **ปุ่มไม่มีรูป** = ไอเทมยังไม่ได้ตั้ง `icon` ในไฟล์ `.tres` (ไม่ใช่ปัญหาโค้ด)
- **ลบ Sprite Frames ออกจาก node แล้วขึ้น error `set_animation: There is no animation with name 'attack'`** = node ยังจำค่า Animation เดิมไว้ในไฟล์ scene พอกด Revert ก็กลายเป็น `animation = &""` ยังขึ้น error อยู่ (Inspector เลือกชื่อท่าไม่ได้เมื่อไม่มี SpriteFrames) → **แก้ด้วยลบ node แล้วสร้างใหม่ชื่อเดิม** (node ใหม่ไม่มีค่าค้าง) หรือลบบรรทัด `animation = ...` ในไฟล์ `.tscn` ตรงๆ (ต้องปิดแท็บ scene ใน Godot ก่อน ไม่งั้นมันเซฟทับกลับ)
- **error `Identifier "..." not declared` ค้างใน log** มักเป็นของตอนพิมพ์โค้ดไปได้ครึ่งเดียว เช็คโค้ดปัจจุบันก่อนตื่นตกใจ

### 3.12 เปลี่ยนชื่อ/ย้ายไฟล์โดยไม่ทำให้ลิงก์พัง
- **ย้ายผ่าน Godot** (ลากในแผง FileSystem / คลิกขวา Rename / MCP `filesystem_manage op=move`) ไม่ใช่ย้ายด้วย File Explorer หรือคำสั่ง shell — Godot อ้างอิงไฟล์ด้วย **uid** เลยยังหาเจอหลังย้าย
- แต่ข้อความ `path="res://..."` ในไฟล์ `.tres` ที่อ้างถึงอาจยังเป็นชื่อเก่า (ทำงานได้เพราะใช้ uid แต่มี warning และอ่านแล้วงง) → **ค้นหาชื่อเก่าทั้งโปรเจกต์แล้วแก้ให้ตรง** จนค้นไม่เจอ แล้วสั่ง scan ใหม่
- ปิดแท็บไฟล์ที่เกี่ยวข้องใน Godot ก่อนแก้ข้อความในไฟล์ ไม่งั้น Godot อาจเซฟ path เก่าทับกลับ
- ห้ามลบไฟล์ `.uid` / `.import` ทิ้งเองตอนย้าย (ดู 5.10)

---

## 4. Input Actions ที่ใช้

| Action | ที่มา | ใช้ทำอะไร |
|---|---|---|
| `ui_left`, `ui_right` | มีให้แล้ว (ค่าเริ่มต้นของ Godot) | เดินซ้าย-ขวา |
| `ui_accept` | มีให้แล้ว (Space/Enter) | กระโดด |
| `dash` | **ต้องสร้างเอง** ผ่าน Project Settings → Input Map | พุ่ง (ผูกปุ่ม Shift) |
| `attack` | **ต้องสร้างเอง** ผ่าน Project Settings → Input Map | โจมตี (ผูกปุ่ม Z) |
| `inventory` | **ต้องสร้างเอง** ผ่าน Project Settings → Input Map | เปิด/ปิดกระเป๋า (ผูกปุ่ม I) |

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

---

## 6. เช็คลิสต์ก่อนบอกว่า "เสร็จแล้ว" (ทำทุกครั้งหลังแก้ `.tscn`/`.gd`)
1. `scene_open(force_reload=true)` เช็ค error ที่โหลดใหม่
2. เช็ค `logs_read(source="editor")` และ `source="game"` ว่ามี error/warning ไหม
3. รันเกมจริงทดสอบ (`project_run`) ไม่ใช่แค่ดูโค้ดเฉยๆ
4. ถ้าเป็น property ของ instance ที่แก้ผ่าน Inspector ให้เช็คว่าไม่ได้ไปสร้าง override ผิดที่ (ดูข้อ 5.8)

---

## 7. Roadmap ที่เหลือ (อ้างอิงจาก `rpg-online-plan.md`)

- [x] Movement + collision (เดิน, กระโดด, พุ่ง, ชนกำแพง)
- [x] ระบบ Stats (HP/MP/EXP/Level) — `StatsData` resource + HUD แสดงหลอด HP เสร็จแล้ว (ยังไม่ live-update รอระบบต่อสู้)
- [x] ระบบต่อสู้พื้นฐาน — โจมตี Dummy ด้วย Area2D hitbox, ลด HP, ตายแล้ว `queue_free()`, มี animation attack จริง
- [x] ระบบ Equipment (ชุดเกราะ + อาวุธ) — `EquipmentData` resource, layered sprite หลายเลเยอร์ (ชุด + ดาบ) sync ด้วย signal, ชุดครบทุกท่า
- [ ] ดาบติดมือ — ทำแล้วเฉพาะท่า `idle` (1 เฟรม) ท่าอื่นดาบจะซ่อน รอทำเฟรมเพิ่มใน Aseprite
- [x] UI Inventory — กด I เปิด, กดไอเทมเพื่อใส่ (ยังไม่มีถอดของ)
- [ ] Item pickup (เก็บของจากพื้น) / ไอเทมใช้แล้วหมด (ยา)
- [ ] Skill system (cooldown, mana cost, effect)
- [ ] Save/Load ตัวละคร (local ก่อน)
- [ ] ค่อยไปแตะ network/multiplayer (Phase 3-4)
