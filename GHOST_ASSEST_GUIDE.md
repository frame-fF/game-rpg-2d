# คู่มือใช้ Ghost Assets กับโปรเจกต์ Godot ใหม่

เอกสารนี้อ่านจบแล้วทำได้เลย ไม่ต้องรู้ประวัติการแกะไฟล์ ไม่ผูกกับโปรเจกต์เก่า
ตัวอย่างโค้ดทั้งหมดเป็น **Godot 4.x (GDScript)**

---

## สารบัญ

1. [ของที่มีอยู่แล้ว](#1-ของที่มีอยู่แล้ว)
2. [โครงสร้างโฟลเดอร์และไฟล์](#2-โครงสร้างโฟลเดอร์และไฟล์)
3. [`_motion.json` — หัวใจของทุกอย่าง](#3-_motionjson--หัวใจของทุกอย่าง)
4. [`_item_index.json` — จาก item ID หาไฟล์](#4-_item_indexjson--จาก-item-id-หาไฟล์)
5. [ระบบพิกัด: วางรูปยังไงให้ตรง](#5-ระบบพิกัด-วางรูปยังไงให้ตรง)
6. [ตัวละครแบบซ้อนชั้น (paperdoll)](#6-ตัวละครแบบซ้อนชั้น-paperdoll)
7. [ชื่อท่าทั้งหมด](#7-ชื่อท่าทั้งหมด)
8. [มอนสเตอร์ / NPC / สัตว์เลี้ยง / เอฟเฟกต์](#8-มอนสเตอร์--npc--สัตว์เลี้ยง--เอฟเฟกต์)
9. [ไอคอนไอเทม](#9-ไอคอนไอเทม)
10. [UI](#10-ui)
11. [ฉากหลังและพื้น](#11-ฉากหลังและพื้น)
12. [เสียง](#12-เสียง)
13. [ขั้นตอนเริ่มโปรเจกต์ใหม่ทีละขั้น](#13-ขั้นตอนเริ่มโปรเจกต์ใหม่ทีละขั้น)
14. [กับดักที่ต้องรู้](#14-กับดักที่ต้องรู้)
15. [สิ่งที่ยังไม่รู้ / ยังไม่ได้แกะ](#15-สิ่งที่ยังไม่รู้--ยังไม่ได้แกะ)
16. [เครื่องมือแปลงไฟล์ (ถ้าต้องแกะใหม่)](#16-เครื่องมือแปลงไฟล์-ถ้าต้องแกะใหม่)

---

## 1. ของที่มีอยู่แล้ว

ทุกอย่างอยู่ที่ **`C:\Users\fF\Desktop\Ghost Assets`** (483,055 ไฟล์, 2.9 GB) แกะจาก `C:\Games\GhostOnlineTH_Client`

| โฟลเดอร์ | ข้างในมีอะไร | ใช้ทำอะไร |
|---|---|---|
| `Avatar/` | ชิ้นส่วนตัวละคร: ตัว ผม ตา หน้า ชุด หมวก ผ้าคลุม อาวุธ เครื่องประดับ | ตัวละครผู้เล่นแบบใส่ชุดเปลี่ยนได้ |
| `OBJ/Monster/` | มอนสเตอร์ 478 ตัว | ศัตรู |
| `OBJ/NPC/` | NPC | คนในเมือง ร้านค้า |
| `OBJ/PET/` | สัตว์เลี้ยง | pet ตามตัว |
| `OBJ/Effect/` | เอฟเฟกต์โจมตี สกิล ระเบิด | VFX |
| `OBJ/Item/`, `OBJ/dp_spend/` | ไอคอนไอเทมทุกชนิด | กระเป๋า ร้านค้า ของดรอป |
| `OBJ/boy`, `OBJ/girl` | ตัวละครพื้นฐานแบบรวมชิ้นเดียว | ทดสอบเร็วๆ |
| `zThailand/ui/` | UI ภาษาไทย: ปุ่ม หน้าต่าง ตัวเลข ช่องไอเทม | HUD เมนู |
| `image/` | UI เพิ่มเติม เคอร์เซอร์ ไอคอน | |
| `Back/` | ภาพพื้นหลัง PNG 184 ภาพ | parallax |
| `Tile/` | ชิ้นพื้น/แท่นหิน PNG 120 ภาพ | ทำด่าน |
| `sound/` | เสียง `.wav` 1,390 + `.mp3` 190 (เพลง 92 + เสียงพากย์ 98) | SFX, BGM |
| `UserData/GuildMark` | ตรากิลด์ `.bmp` 552 ภาพ | |
| `_item_index.json` | item ID → โฟลเดอร์ (ดูหัวข้อ 4) | ฐานข้อมูลไอเทม |
| `_tools/` | สคริปต์ Python ที่ใช้แกะไฟล์ + รูปตัวอย่าง `paperdoll.png` | แกะใหม่ / ตรวจผล |

รูปทั้งหมดเป็น **PNG พื้นโปร่งใส (RGBA)** ใช้ใน Godot ได้ทันที

---

## 2. โครงสร้างโฟลเดอร์และไฟล์

มี 2 แบบ:

**แบบ A: 1 โฟลเดอร์ = 1 ตัว** (มอนสเตอร์, NPC, ตัวละครรวม)
```
OBJ/Monster/m010005/
    000.png
    001.png
    ...
    _motion.json        ← ท่าทาง (บางตัวไม่มี)
```

**แบบ B: 1 โฟลเดอร์ = หลายชิ้น** (ชิ้นส่วนตัวละคร, ไอคอน, เอฟเฟกต์)
```
Avatar/avatar_dress/
    000_d_m_t_000/      ← <ลำดับ 3 หลัก>_<ชื่อชิ้นในเกม>
        000.png ...
        _motion.json    ← มี item_ids ด้วย
    002_d_m_m_001/
        ...
```

**เลข PNG อาจข้าม** เช่นมี `000`, `001`, `003` แต่ไม่มี `002` แปลว่าเฟรมนั้นว่างเปล่า (ขนาด 0) ห้ามเขียนโค้ดวนโหลดแบบ "โหลดไปเรื่อยๆ จนไม่เจอไฟล์" ให้โหลดตามเลข `frame` ใน JSON เท่านั้น

---

## 3. `_motion.json` — หัวใจของทุกอย่าง

ไฟล์นี้บอกว่า**แต่ละท่าใช้รูปไหน วางตรงไหน ค้างนานเท่าไร ซ้อนชั้นไหน**

```json
{
  "source": "avatar_dress.csp #2",
  "item_ids": [8110011, 18110011, 8150011],
  "note": "...",
  "motions": [
    {
      "name": "STAND_1",
      "frames": [
        {"frame": 0, "delay": 7, "x": -1, "y": -23, "layer": 6, "sound": 0, "raw": [0, 7, -1, -23, 0, 6, -1, 0, 0, 0, -1, 0, 0, 0, 0]},
        {"frame": 1, "delay": 7, "x": -2, "y": -23, "layer": 6, "sound": 0, "raw": [...]}
      ]
    },
    {"name": "WALK_1", "frames": [...]}
  ]
}
```

| ฟิลด์ | ความหมาย | ความมั่นใจ |
|---|---|---|
| `name` | ชื่อท่า (ดูหัวข้อ 7) | ✅ |
| `frame` | เลขไฟล์ PNG: `frame: 3` → `003.png` เฟรมเดียวกันใช้ซ้ำได้หลายครั้ง | ✅ |
| `x`, `y` | ตำแหน่ง **กึ่งกลางรูป** เทียบกับ **จุดเท้าตัวละคร** (หน่วยพิกเซล, y ติดลบ = ขึ้นบน) | ✅ ทดสอบแล้ว |
| `layer` | ลำดับซ้อน ยิ่งมากยิ่งอยู่หน้า **เปลี่ยนได้ในแต่ละเฟรม** | ✅ |
| `delay` | เวลาค้างเฟรม หน่วย tick ของเกมต้นฉบับ | ⚠️ ไม่รู้ว่า 1 tick กี่ ms (เริ่มที่ 1/30 วิ แล้วจูนด้วยตา) |
| `sound` | รหัสเสียงที่เล่นตอนถึงเฟรมนี้ (0 = ไม่มี) | ⚠️ เดา ยังไม่รู้ว่ารหัสไหนคือไฟล์ไหน |
| `item_ids` | item ID ในเกมต้นฉบับที่ใช้ชิ้นนี้ (มีเฉพาะแบบ B) | ✅ |
| `raw` | ค่าดิบ 15 ช่อง: `[0]=frame [1]=delay [2]=x [3]=y [5]=layer [14]=sound` ที่เหลือยังไม่รู้ (น่าจะเป็นจุดปล่อยเอฟเฟกต์/ลูกธนู) | — |

**โฟลเดอร์ที่ไม่มี `_motion.json`** มี 2 กรณี:
- ไอคอน / UI / รูปนิ่ง ใช้ PNG ตรงๆ ได้เลย
- มอนสเตอร์หรือเอฟเฟกต์บางตัวที่เกมต้นฉบับไม่มีไฟล์ท่า ให้เล่นทุกเฟรมเรียงกันเองด้วย `AnimatedSprite2D`

---

## 4. `_item_index.json` — จาก item ID หาไฟล์

`Ghost Assets\_item_index.json` จับคู่ **item ID → ทุกโฟลเดอร์ที่ใช้ ID นั้น** (21,489 ID)

```json
"8110011": [
  "Avatar/avatar_dress/002_d_m_m_001",     ← ชิ้นชุดที่ใส่บนตัว
  "Avatar/dress/002_d_m_m_001",            ← ชิ้นเดียวกัน (ไฟล์รุ่นเก่า)
  "OBJ/Item/dp_dress/000_무사평복_남",      ← ไอคอนในกระเป๋า
  "OBJ/Item/dress/000_무사평복_남"          ← ไอคอน (ไฟล์รุ่นเก่า)
]
```

ใช้ตอนสร้างฐานข้อมูลไอเทม: 1 ไอเทม = ไอคอน (`OBJ/Item/...`) + ชิ้นที่ใส่ (`Avatar/...`)

**ช่วง ID คร่าวๆ** (ดูจากข้อมูล ไม่ใช่กฎตายตัว):

| ขึ้นต้นด้วย | ส่วนใหญ่เป็น |
|---|---|
| `110`, `111`, `119`, `880`, `884`, `885`, `889` | ของใช้ / ยา / วัตถุดิบ (`dp_spend`) |
| `180`, `179` (8 หลัก) | อาวุธ |
| `181`, `815`, `951` | ชุด |
| `849` | ผ้าคลุม |
| `861`, `865` | หมวก |
| `871`, `941` | หน้า |
| `900`, `901`, `905` | ผม / สีผิว (`9000001`–`9000028` = ผิว) |
| `915` | ตา |
| `730` | เครื่องประดับผม |
| `741` | อาวุธเสริม |
| `921`, `923` | สัตว์เลี้ยง / ของเล่น pet |

**ชื่อ/ราคา/สเตตัสไอเทมไม่มีในนี้** อยู่ในไฟล์ `.tbl` ที่ยังไม่ได้แกะ (หัวข้อ 15) ต้องตั้งเอง

---

## 5. ระบบพิกัด: วางรูปยังไงให้ตรง

```
             ↑ y ติดลบ
             │
   ┌─────────┼─────────┐
   │     (x,y) = กึ่งกลางรูป
   │         ●         │
   └─────────┼─────────┘
             │
 ────────────◆──────────── พื้น   ◆ = (0,0) = จุดเท้า (origin ของตัวละคร)
```

**สูตร:** มุมซ้ายบนของรูป = `(x - width/2, y - height/2)` (หารปัดลงแบบจำนวนเต็ม)

ใน Godot ใช้ `Sprite2D` ตั้ง `centered = false` แล้ว:
```gdscript
sprite.offset = Vector2(x - tex.get_width() / 2, y - tex.get_height() / 2)
```
แบบนี้ตรงกับเกมต้นฉบับทุกพิกเซล ถ้าใช้ `centered = true` + `offset = Vector2(x, y)` รูปที่ขนาดเป็นเลขคี่จะเลื่อนครึ่งพิกเซลแล้วดูสั่น

**ทิศทาง:** สไปรต์ทุกตัว**หันซ้าย** ถ้าจะให้หันขวา ให้ตั้ง `scale.x = -1` ที่ node แม่ ห้าม flip ทีละ Sprite เพราะ offset จะไม่กลับตาม

---

## 6. ตัวละครแบบซ้อนชั้น (paperdoll)

### 6.1 หลักการ

ตัวละคร 1 ตัว = หลายชิ้นซ้อนกัน **ทุกชิ้นมีท่าชื่อเดียวกันและจำนวนเฟรมเท่ากัน** ใช้จังหวะของ "ตัว" (body) เป็นตัวกำหนด แล้วทุกชิ้นแสดงเฟรมเดียวกัน

ดูตัวอย่างผลลัพธ์ได้ที่ `Ghost Assets\_tools\paperdoll.png` (ตัว + ชุด + ผม + ผ้าคลุม + ดาบ ใน 4 ท่า)

### 6.2 ชิ้นส่วนและลำดับชั้น

| slot | โฟลเดอร์ใน `Avatar/` | `layer` ที่พบ | หมายเหตุ |
|---|---|---|---|
| `mantle` | `Avatar_mantle`, `mantle` | -4 | อยู่หลังตัว |
| `weapon_acc` | `Avatar_weaponacc`, `weaponacc` | -1 / 14 | สลับหน้า-หลังตามท่า |
| `body` | `avatar_skin` | 0 | **ต้องมีเสมอ** |
| `face` | `Avatar_face`, `face`, `avatar_face_2`, `face_2` | 4–5 | |
| `dress` | `avatar_dress`, `avatar_dress1`, `avatar_dress_2`, `avatar_dress_2_2`, `Avatar_dress_2_3`, `dress*` | 6 | ชุดทั้งตัว (รวมรองเท้า) |
| `eye` | `Avatar_eye`, `eye` | 10 | |
| `hair` | `Avatar_hair`, `hair` | 10 | |
| `hat` | `Avatar_hat`, `hat` | 10–12 | |
| `weapon` | `Avatar_weapon`, `weapon` | 14 | |
| `hair_acc` | `avatar_hairaccessory`, `hairaccessory` | 15 | |

- **`Avatar_xxx` กับ `xxx`** คือไฟล์รุ่นใหม่กับรุ่นเก่า ของใหม่มีมากกว่า ใช้ `Avatar_xxx` เป็นหลัก
- **ตัว (`avatar_skin`)** มี 28 แบบ: `000_boy_blue`, `001_girl_blue`, `002_boy_bright`, `004_boy`, `005_girl`, … `skin14_rainbow_*` (ชาย = เลขคู่, หญิง = เลขคี่)
- **เพศ** ดูจากชื่อชิ้น: `_m_` = ชาย, `_w_` = หญิง, `_c_` = ใช้ร่วมกัน เช่น `d_m_m_001` (ชุดชาย), `h_w_t_000` (ผมหญิง), `w_c_m_001` (อาวุธใช้ร่วม)
- **ชุดของ Ghost ใช้ได้กับตัวของ Ghost เท่านั้น** ตำแหน่งทำมาพอดีกับ `avatar_skin` ถ้าวาดตัวเอง ต้องวาดชุดเองด้วย

### 6.3 โค้ด: `GhostPart` — โหลด 1 โฟลเดอร์

```gdscript
# ghost_part.gd
class_name GhostPart
extends RefCounted
## One exported Ghost Online sprite folder: NNN.png frames + optional _motion.json.

static var _cache: Dictionary = {}  # dir -> GhostPart

var dir: String
var item_ids: Array = []
var motions: Dictionary = {}  # StringName -> Array[Dictionary]
var _textures: Dictionary = {}  # int -> Texture2D (null = empty frame)


static func from_dir(path: String) -> GhostPart:
	if _cache.has(path):
		return _cache[path]
	var part := GhostPart.new()
	part.dir = path
	var json_path := path.path_join("_motion.json")
	if FileAccess.file_exists(json_path):
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(json_path))
		part.item_ids = data.get("item_ids", [])
		for m in data["motions"]:
			part.motions[StringName(m["name"])] = m["frames"]
	_cache[path] = part
	return part


func texture(index: int) -> Texture2D:
	if not _textures.has(index):
		var png := dir.path_join("%03d.png" % index)
		_textures[index] = load(png) if ResourceLoader.exists(png) else null
	return _textures[index]


func frames_of(motion: StringName) -> Array:
	return motions.get(motion, [])
```

### 6.4 โค้ด: `Paperdoll` — ประกอบชิ้นและเล่นท่า

```gdscript
# paperdoll.gd
class_name Paperdoll
extends Node2D
## Stacks GhostParts; the "body" slot drives timing, every slot shows the same frame index.

signal motion_finished(motion: StringName)

## Seconds per Ghost "delay" tick. Unknown in the original engine — tune by eye.
@export var tick_sec: float = 1.0 / 30.0

var motion: StringName = &"STAND_1"
var looping := true
var _parts: Dictionary = {}    # slot -> GhostPart
var _sprites: Dictionary = {}  # slot -> Sprite2D
var _frame := 0
var _elapsed := 0.0
var _done := false


func set_part(slot: StringName, part: GhostPart) -> void:
	if part == null:
		_parts.erase(slot)
		if _sprites.has(slot):
			_sprites[slot].queue_free()
			_sprites.erase(slot)
		return
	_parts[slot] = part
	if not _sprites.has(slot):
		var sprite := Sprite2D.new()
		sprite.centered = false
		add_child(sprite)
		_sprites[slot] = sprite
	_apply()


func play(new_motion: StringName, loop := true) -> void:
	if new_motion == motion and not _done:
		return
	motion = new_motion
	looping = loop
	_frame = 0
	_elapsed = 0.0
	_done = false
	_apply()


## Ghost sprites face left; call with true to face right.
func face_right(right: bool) -> void:
	scale.x = -1.0 if right else 1.0


func _process(delta: float) -> void:
	var frames := _body_frames()
	if frames.is_empty() or _done:
		return
	_elapsed += delta
	var duration := maxf(1.0, frames[_frame]["delay"]) * tick_sec
	while _elapsed >= duration:
		_elapsed -= duration
		if _frame + 1 < frames.size():
			_frame += 1
		elif looping:
			_frame = 0
		else:
			_done = true
			motion_finished.emit(motion)
			break
		duration = maxf(1.0, frames[_frame]["delay"]) * tick_sec
	_apply()


func _body_frames() -> Array:
	var body: GhostPart = _parts.get(&"body")
	return body.frames_of(motion) if body else []


@warning_ignore("integer_division")
func _apply() -> void:
	for slot in _parts:
		var sprite: Sprite2D = _sprites[slot]
		var frames: Array = _parts[slot].frames_of(motion)
		if _frame >= frames.size():
			sprite.visible = false
			continue
		var f: Dictionary = frames[_frame]
		var tex: Texture2D = _parts[slot].texture(int(f["frame"]))
		sprite.visible = tex != null
		if tex == null:
			continue
		sprite.texture = tex
		sprite.offset = Vector2(int(f["x"]) - tex.get_width() / 2, int(f["y"]) - tex.get_height() / 2)
		sprite.z_index = int(f["layer"])
```

### 6.5 ใช้งาน

```gdscript
# player.gd (ตัวอย่าง)
extends CharacterBody2D

const GHOST := "res://ghost/"   # โฟลเดอร์ที่ copy ชิ้นส่วนเข้ามา

@onready var doll: Paperdoll = %Paperdoll

func _ready() -> void:
	doll.set_part(&"body", GhostPart.from_dir(GHOST + "Avatar/avatar_skin/004_boy"))
	doll.set_part(&"dress", GhostPart.from_dir(GHOST + "Avatar/avatar_dress/002_d_m_m_001"))
	doll.set_part(&"hair", GhostPart.from_dir(GHOST + "Avatar/Avatar_hair/000_h_m_t_000"))
	doll.set_part(&"mantle", GhostPart.from_dir(GHOST + "Avatar/Avatar_mantle/002_c_m_c_c_001"))
	doll.set_part(&"weapon", GhostPart.from_dir(GHOST + "Avatar/Avatar_weapon/002_w_c_m_001"))
	doll.play(&"STAND_1")

func _physics_process(_delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		doll.face_right(dir > 0.0)
		doll.play(&"WALK_1")
	else:
		doll.play(&"STAND_1")
```

ถอดชุด: `doll.set_part(&"dress", null)` · ท่าเล่นครั้งเดียว: `doll.play(&"ATTACK_1", false)` แล้วรอ `motion_finished`

**โครง scene:**
```
Player (CharacterBody2D)
├── Paperdoll (Node2D, paperdoll.gd, z_index = 10)   ← %Paperdoll, วางให้ (0,0) ตรงเท้า
└── CollisionShape2D                                  ← ให้ขอบล่างอยู่ที่ y = 0
```
ตั้ง `z_index = 10` ที่ Paperdoll เพราะผ้าคลุมมี layer -4 ถ้า parent เป็น 0 ผ้าคลุมจะไปอยู่หลังพื้น (z ของลูกบวกกับของ parent)

---

## 7. ชื่อท่าทั้งหมด

### ตัวละครผู้เล่น (ทุกชิ้นใน `Avatar/` มีชุดเดียวกัน 32 ท่า)

ความหมายแปลจากชื่อท่า ส่วนที่มีคำว่า "น่าจะ" ยังไม่ได้เปิดดูรูปยืนยัน

| ท่า | ความหมาย | เฟรม (ตัว) |
|---|---|---|
| `STAND_1` | ยืน | 4 |
| `WALK_1` | เดิน | 6 |
| `RUN_1` | วิ่ง/พุ่ง (ตัวเอนไปหน้า เหมาะใช้เป็น dash) | 3 |
| `LJUMP_1`, `LJUMP_2` | กระโดดต่ำ (ขึ้น / ลง) | 1 / 1 |
| `HJUMP_1`–`HJUMP_4` | กระโดดสูง น่าจะเป็น เตรียม / ขึ้น / จุดสูงสุด / ลง | 1 ต่อท่า |
| `ASTAND_1` | ยืนท่าต่อสู้ | 4 |
| `AREADY_1` | ตั้งท่า | 1 |
| `ATTACK_1`–`ATTACK_7` | โจมตี 7 แบบ | 4–7 |
| `DEFENSE_1` | ป้องกัน | 1 |
| `DAMAGE_1`, `DAMAGE_2` | โดนตี | 1 |
| `SPELL_1`–`SPELL_3` | ร่ายเวท | 8 / 4 / 12 |
| `DEAD_1` | ตาย | 2 |
| `SCREAM_1` | ตะโกน น่าจะใช้ตอนบัฟ | 3 |
| `STRETCH_1` | น่าจะเป็นบิดขี้เกียจ (idle พิเศษ) | 4 |
| `STICK_1`–`STICK_3` | น่าจะเป็นเกาะ / ปีนเชือก-บันได | 1 |
| `UPPER_1`, `UPPER_2` | น่าจะเป็นโจมตีขึ้นด้านบน | 1 |

ไม่มีท่า **dash** แยก ใช้ `RUN_1` แทนได้ ถ้าต้องการท่าใหม่ ต้องวาดให้ครบทุกชิ้น

### มอนสเตอร์ (`OBJ/Monster`, 475 ตัวที่มีท่า)
`STAND_1` (449 ตัว), `DEAD_1` (447), `DAMAGE_1` (445), `ATTACK_1` (430), `ATTACK_2` (322), `WALK_1` (288), `DAMAGE_2`, `LJUMP_1-2`, `START_1` (ท่าเกิด), `MOVE_1` (156), `DEAD_2`
**ไม่ใช่ทุกตัวจะมีครบ** เช็คด้วย `part.motions.has(&"WALK_1")` ถ้าไม่มี `WALK_1` ให้ลอง `MOVE_1`

### NPC (`OBJ/NPC`)
ไม่มีมาตรฐาน: `STAND_1`, `stand_1`, `STAND_2`, `MOVE_1`, `0_stand`, `기본` (เกาหลีแปลว่า "พื้นฐาน") ฯลฯ ส่วนใหญ่ใช้แค่ท่าแรกใน `motions`

### สัตว์เลี้ยง (`OBJ/PET`)
`STAND_1-3`, `RUN_1`, `JUMP_1`, `WALK_1`, `ASTAND_1`, `AREADY_1`, `ATTACK_1-2`, `DEAD_1` บางตัวมี `DAMAGE_1`, `ANGRY_1`

### เอฟเฟกต์ (`OBJ/Effect`)
ชื่อท่าส่วนใหญ่ว่าง (`""`) หรือเป็นภาษาเกาหลี: `공격` (โจมตี), `이펙트` (เอฟเฟกต์), `명중` (โดนเป้า), `발사` (ยิง), `시전` (ร่าย), `발동` (ทำงาน), `폭발` (ระเบิด), `타격` (กระแทก), `대기` (รอ) ใช้ท่าแรกที่มีได้เลย

---

## 8. มอนสเตอร์ / NPC / สัตว์เลี้ยง / เอฟเฟกต์

ใช้ `Paperdoll` ตัวเดิม ใส่แค่ slot `body` ชิ้นเดียว:

```gdscript
# monster.gd
extends CharacterBody2D

@export_dir var sprite_dir: String = "res://ghost/OBJ/Monster/m010005"

@onready var doll: Paperdoll = %Paperdoll

func _ready() -> void:
	var part := GhostPart.from_dir(sprite_dir)
	doll.set_part(&"body", part)
	doll.play(&"START_1" if part.motions.has(&"START_1") else &"STAND_1", false)
	doll.motion_finished.connect(_on_motion_finished)

func _on_motion_finished(motion: StringName) -> void:
	match motion:
		&"START_1", &"ATTACK_1", &"DAMAGE_1":
			doll.play(&"STAND_1")
		&"DEAD_1":
			queue_free()
```

**เอฟเฟกต์ที่ไม่มี `_motion.json`** ให้สร้าง `SpriteFrames` จาก PNG ทุกไฟล์แล้วใช้ `AnimatedSprite2D` ธรรมดา (ตั้ง `centered = true`) ตำแหน่งจะไม่ตรงเป๊ะเท่าแบบมี JSON แต่ใช้ได้

**hitbox:** ไฟล์ต้นฉบับมีกรอบ hitbox ต่อเฟรม แต่**ไม่ได้ export ออกมา** ให้ตั้ง `CollisionShape2D` เองจากขนาดรูปเฟรมยืน

---

## 9. ไอคอนไอเทม

อยู่ที่ `OBJ/Item/<หมวด>/<ลำดับ>_<ชื่อ>/000.png` เป็นรูปนิ่งเฟรมเดียว (ประมาณ 32×32)

| หมวด | เนื้อหา |
|---|---|
| `DP_weapon`, `weapon` | อาวุธ |
| `DP_dress`, `dress`, `DP_dress2*` | ชุด |
| `DP_hair`, `hair`, `DP_hat` ... | ผม หมวก ฯลฯ |
| `DP_spend`, `OBJ/dp_spend` | ของใช้ ยา วัตถุดิบ |
| `DP_other`, `dp_other_mob` | ของดรอปจากมอน อื่นๆ |
| `DP_pet`, `pet` | สัตว์เลี้ยง |
| `ring`, `necklace`, `earring`, `bracelet`, `DP_Belt`, `DP_CurvedJade` | เครื่องประดับ |

`DP_xxx` กับ `xxx` เป็นรูปเดียวกัน (DP = ชุดใหม่กว่า) ใช้ `DP_xxx` เป็นหลัก หาไอคอนของไอเทมจาก item ID ได้ด้วย `_item_index.json` (เลือก path ที่ขึ้นต้นด้วย `OBJ/Item` หรือ `OBJ/dp_spend`)

```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var ghost_id: int
@export var item_name: String
@export var icon: Texture2D                          # OBJ/Item/.../000.png
@export_dir var equip_dir: String                    # Avatar/... (ว่าง = ใส่ไม่ได้)
@export_enum("dress", "hair", "hat", "mantle", "weapon", "face", "eye", "hair_acc", "weapon_acc") var slot: String
```
ใส่ของ: `doll.set_part(StringName(item.slot), GhostPart.from_dir(item.equip_dir))`

---

## 10. UI

อยู่ที่ `zThailand/ui/<หมวด>/<ชื่อ>/000.png, 001.png, ...` ข้อความบนปุ่มเป็น**ภาษาไทยในตัวรูป**แล้ว

| หมวด | ตัวอย่าง |
|---|---|
| `common` | `btn_ok`, `btn_cancel`, `btn_buy_ok`, `number`, `number0`, `number1`, `slider`, `check_1`, `ItemInfo`, `quest_number` |
| `cashshop` | ปุ่มร้านค้า |
| `community` | ปุ่มส่งข้อความ radio |
| `login`, `login/create character` | หน้า login และสร้างตัวละคร |

**ปุ่มส่วนใหญ่มี 3 เฟรม:** `000` = ปกติ, `001` = เมาส์ชี้, `002` = กด ⚠️ ลำดับยังไม่ได้ยืนยัน ให้เปิดดูก่อน ใช้กับ `TextureButton`:

```gdscript
var b := TextureButton.new()
b.texture_normal = load("res://ghost/zThailand/ui/common/btn_ok/000.png")
b.texture_hover = load("res://ghost/zThailand/ui/common/btn_ok/001.png")
b.texture_pressed = load("res://ghost/zThailand/ui/common/btn_ok/002.png")
```

**ตัวเลข:** `number`, `number0`, `number1` คือฟอนต์ตัวเลข 3 แบบ **1 เฟรม = 1 ตัวเลข** (`number0` มี 11 เฟรม, `number1` มี 13 เฟรม) ⚠️ ลำดับไม่ได้เริ่มที่ 0: ใน `number0` เฟรม `003` คือเลข "4" ให้เปิดดูทุกเฟรมแล้วทำตาราง map ก่อนใช้ ใช้ทำตัวเลขดาเมจหรือเลเวลโดยต่อรูปทีละหลัก (`HBoxContainer` + `TextureRect`)

หน้าต่าง/กรอบใช้ `NinePatchRect` แล้วตั้ง `patch_margin_*` ให้มุมไม่ยืด

---

## 11. ฉากหลังและพื้น

### ฉากหลัง `Back/*.png`
- ชื่อไฟล์บอกชุด: `45_0.png` กับ `45_0_s.png` เป็นของด่าน 45 ทั้งคู่ (`_s` เป็นรูปขนาดเล็กกว่า ⚠️ เดาว่าเป็นชั้นไกลของ parallax ยังไม่ได้ยืนยัน)
- ขนาดมีหลายแบบ: 256², 512², 800×600, 1280×1024
- ใช้ `Parallax2D` (Godot 4.3+) หรือ `ParallaxBackground` + `ParallaxLayer`:
  - ชั้นไกล: `scroll_scale = Vector2(0.2, 0.2)`, ชั้นกลาง: 0.5
  - ถ้าให้ภาพต่อกันแนวนอน ตั้ง `repeat_size.x = ความกว้างรูป`
- ตั้ง `z_index` ให้ติดลบมากๆ (เช่น -100) หรือวางใน `CanvasLayer` ที่ `layer = -1` จะได้อยู่หลังตัวละครเสมอ

### พื้น `Tile/*.png`
- `1.png`, `46_1.png` ฯลฯ เป็น **atlas 1024×1024** รวมชิ้นแท่นหิน หญ้า หน้าผา ขนาดไม่เท่ากัน **ไม่ใช่ grid สี่เหลี่ยมเท่ากัน**
- `_0_00.png`, `t14_2_00.png` … เป็น atlas 256×256 หลายแผ่นจากไฟล์เดียว
- วิธีที่ง่ายที่สุด: `Sprite2D` ตั้ง `region_enabled = true` แล้วตัดชิ้นที่ต้องการ วางเป็นแท่น แล้วใส่ `StaticBody2D` + `CollisionShape2D` ไว้ที่ขอบบน (หรือ `one_way_collision` ถ้าเป็นแท่นที่กระโดดทะลุขึ้นได้)
- ถ้าอยากใช้ `TileMapLayer` ต้องตัด atlas เป็นชิ้นขนาดเท่ากันเอง (เช่น 32×32) งานเยอะ ไม่แนะนำ

เลย์เอาต์แผนที่จริงของเกม (`.map`) **ยังไม่ได้แกะ** ต้องออกแบบด่านเอง

---

## 12. เสียง

`sound/` ใช้ได้ตรงๆ (Godot import `.wav`/`.mp3` ได้เลย)

| โฟลเดอร์ | จำนวน | เนื้อหา | ตัวอย่าง |
|---|---|---|---|
| `BGM/` | 92 | เพลงประจำด่าน `.mp3` | `bgm_bigtreetown.mp3`, `bgm_blackhill.mp3` |
| `Cha_Effect/` | 31 | เสียงตัวละคร | `Cha_Jump_1.wav`, `Cha_DJ_pierce.wav` |
| `Mob_Effect/` | 599 | เสียงมอน | `03_Attack.wav`, `01_Death.wav` |
| `Skill_Effect/` | 379 | เสียงสกิล | `Skill_2BK_1.wav` |
| `Ui_Effect/` | 27 | เสียง UI | `UI_buttonselect.wav`, `UI_itempickup.wav` |
| `ETC/` | 70 | อื่นๆ | `ETC_damage01.wav` |
| `Voice/` | 98 | เสียงพากย์ NPC | `bookseller_01.mp3` |
| ราก `sound/` | | เสียงมอนบางตัว | `120a_attack1.wav`, `120a_death.wav` |

- เพลง: `AudioStreamPlayer` เปิด loop ใน Import dock (`.mp3` → Loop)
- เสียงในฉาก: `AudioStreamPlayer2D` (เบาลงตามระยะ)
- รหัส `sound` ใน `_motion.json` **ไม่ตรงกับชื่อไฟล์** (ตารางจับคู่อยู่ใน `.tbl` ที่ยังไม่ได้แกะ) ให้ผูกเสียงกับท่าเอง เช่น "เล่น `03_Attack.wav` ตอนเริ่ม `ATTACK_1`"

---

## 13. ขั้นตอนเริ่มโปรเจกต์ใหม่ทีละขั้น

1. **สร้างโปรเจกต์ Godot 4** แล้วตั้งค่าใน Project Settings:
   - `Rendering > Textures > Canvas Textures > Default Texture Filter` = **Nearest** (ภาพพิกเซลคม ไม่เบลอ)
   - `Rendering > 2D > Snap > Snap 2D Transforms to Pixel` = **On** (ไม่สั่นตอนกล้องขยับ)
   - `Display > Window > Stretch > Mode` = `canvas_items`, ตั้งความละเอียดเล็ก (เช่น 800×600 เท่าเกมต้นฉบับ)
2. **สร้างโฟลเดอร์ `res://ghost/`** แล้ว **copy เฉพาะของที่ใช้** เข้ามาโดยรักษาโครงสร้าง path เดิม เช่น
   `Ghost Assets\Avatar\avatar_skin\004_boy` → `res://ghost/Avatar/avatar_skin/004_boy`
   ห้าม copy ทั้ง 2.9 GB เข้าไป (ดูหัวข้อ 14)
3. **ใส่ `ghost_part.gd` และ `paperdoll.gd`** จากหัวข้อ 6
4. **ทำ Player** ตามโครงในหัวข้อ 6.5 → กด F6 ต้องเห็นตัวละครยืนหายใจ
5. **จูน `tick_sec`** ที่ Paperdoll จนท่าเดินดูเป็นธรรมชาติ แล้วใช้ค่านั้นทั้งเกม
6. **ทำมอนสเตอร์** จากหัวข้อ 8
7. **ทำ ItemData** (หัวข้อ 9) โดยใช้ `_item_index.json` หาไอคอนกับชิ้นส่วนที่ใส่
8. **UI / ฉากหลัง / เสียง** ตามหัวข้อ 10–12
9. **ตั้งค่า Export:** ใน export preset ช่อง *Filters to export non-resource files/folders* ใส่ `*.json` ไม่อย่างนั้น `_motion.json` จะไม่ติดไปกับเกม (ดูหัวข้อ 14)

---

## 14. กับดักที่ต้องรู้

| ปัญหา | สาเหตุ | ทางแก้ |
|---|---|---|
| Godot ค้างนานมาก / โปรเจกต์ใหญ่ขึ้นหลาย GB | copy PNG หลายแสนไฟล์เข้าไป ทุกไฟล์ต้อง import + สร้าง `.import` | copy แค่โฟลเดอร์ที่ใช้จริง |
| รันใน editor ได้ แต่ export แล้วตัวละครไม่ขยับ | `.json` ไม่ใช่ resource เลยไม่ถูก export | เพิ่ม `*.json` ใน export filter หรือแปลง JSON เป็น `.tres` |
| ชิ้นส่วนเลื่อนจากตัวครึ่งพิกเซล / สั่น | ใช้ `centered = true` กับรูปขนาดคี่ | ใช้ `centered = false` + สูตรในหัวข้อ 5 |
| หันขวาแล้วชุดหลุดจากตัว | flip ทีละ Sprite (`flip_h`) ซึ่งไม่กลับ offset ด้วย | flip ที่ node แม่ด้วย `scale.x = -1` |
| ผ้าคลุมหายไปหลังพื้น | `z_index` -4 บวกกับ parent 0 | ตั้ง `z_index` ของ Paperdoll ให้สูงพอ (เช่น 10) |
| อาวุธซ้อนผิดในบางท่า | ตั้ง `z_index` ตายตัวต่อชิ้น | ตั้งจาก `layer` ของเฟรมนั้นทุกครั้ง (โค้ดในหัวข้อ 6.4 ทำแล้ว) |
| ชุดไม่พอดีตัว | เอาชุด Ghost ไปใส่ตัวที่วาดเอง | ชุดกับตัวต้องมาจากที่เดียวกัน |
| ท่าหายไปบางชิ้น | ชิ้นนั้นไม่มีท่านั้น | `Paperdoll` ซ่อนชิ้นนั้นให้อัตโนมัติ |
| โหลดเฟรมแล้ว error ตรงกลาง | เลข PNG ข้าม (เฟรมว่าง) | โหลดตามเลข `frame` ใน JSON (`GhostPart.texture()` คืน `null` ให้เอง) |
| ภาพเบลอ | filter ค่าเริ่มต้นเป็น Linear | ตั้ง Default Texture Filter = Nearest |
| ชื่อโฟลเดอร์เป็นภาษาเกาหลี/ไทย | ชื่อจากเกมต้นฉบับ | Godot รองรับ Unicode path แต่ถ้ามีปัญหาตอน export ให้เปลี่ยนชื่อเป็นอังกฤษตอน copy |

---

## 15. สิ่งที่ยังไม่รู้ / ยังไม่ได้แกะ

| เรื่อง | สถานะ | ผลกระทบ |
|---|---|---|
| หน่วยของ `delay` | ไม่รู้ | ต้องจูน `tick_sec` ด้วยตา |
| รหัส `sound` → ไฟล์เสียง | ไม่รู้ (น่าจะอยู่ใน `.tbl`) | ผูกเสียงเอง |
| ช่อง `raw[6..13]` | ไม่รู้ (น่าจะเป็นจุดปล่อยเอฟเฟกต์/กระสุน) | กำหนดจุดยิงเอง |
| hitbox ต่อเฟรม | มีในไฟล์ต้นฉบับ แต่ไม่ได้ export | ตั้ง collision เอง |
| ลำดับเฟรมปุ่ม UI (ปกติ/ชี้/กด) | เดา | เปิดดูก่อนใช้ |
| `.map` (782 ไฟล์) | ไม่ได้แกะ | ไม่มีเลย์เอาต์ด่านจริง |
| `.prj` (1,305) | ไม่ได้แกะ | ข้อมูลฉาก |
| `.luc` / `.lua` (~935) | ไม่ได้แกะ (Lua ที่ compile แล้ว) | เควส/บทพูด NPC |
| `.tbl`, `.etb`, `.att`, `.cob` | ไม่ได้แกะ | ชื่อไอเทม สเตตัส ราคา ตารางเสียง collision ของพื้น |
| `M000011.spr` | ถูกเข้ารหัส | ไม่มีไฟล์ไหนใช้ ไม่กระทบ |
| `M000012.spr` | ข้อมูลเสีย | ไม่มีไฟล์ไหนใช้ ไม่กระทบ |

---

## 16. เครื่องมือแปลงไฟล์ (ถ้าต้องแกะใหม่)

อยู่ที่ `Ghost Assets\_tools\` ต้องใช้ Python 3.12 (`compose.py`/`paperdoll.py` ต้องมี Pillow ด้วย) path ต้นทางและปลายทางเขียนไว้ตรงๆ ในสคริปต์ (`ROOT` ใน `mot.py`, `DST` ใน `spr2png.py`)

| สคริปต์ | หน้าที่ | สั่งรัน |
|---|---|---|
| `spr2png.py` | อ่าน `.spr`/`.csp` → PNG (ไม่ต้องใช้ Pillow) | ใช้ผ่านสคริปต์อื่น |
| `mot.py` | อ่าน `.mot` → `_motion.json` ทุกไฟล์ | `python mot.py` |
| `cmo.py` | อ่าน `.cmo` (ท่าทางของ `.csp`) | `python cmo.py` = ตรวจทุกไฟล์ |
| `avatar_export.py` | `.csp` + `.cmo` → PNG + `_motion.json` | `python avatar_export.py` (Avatar) / `--non-avatar` (ที่เหลือ) / ระบุชื่อไฟล์ |
| `bgtil.py` | `.bg`/`.til` → PNG | ใช้ผ่าน `rest.py` |
| `rest.py` | UI นอก `data/`, bg/til, copy เสียง/bmp/avi | `python rest.py` |
| `build_index.py` | สร้าง `_item_index.json` | `python build_index.py` |
| `paperdoll.py` | ประกอบตัวละครจาก `Ghost Assets` → `paperdoll.png` ไว้ตรวจตำแหน่ง | `python paperdoll.py` |

### รูปแบบไฟล์ต้นฉบับ (สรุป)
ทุกไฟล์เป็น little-endian ข้อความเป็น CP949 (เกาหลี)

- **`.spr`:** name 0x80 ×2 · `u32 frames` @0x100 · ต่อเฟรม: `u32 id`, `u32 n + n×16B rect`, `u32 m + m×16B rect`, block 16B (`01 03`=ARGB1555 / `01 04`=BGRA8888 … `00 ff 00 ff`), `u16 w, 2B, u16 h, 2B, u32 pixel_count`, พิกเซล (ใช้ w×h แรก)
- **`.mot`:** name 0x80 ×2 · `u32 motions` @0x100 · ต่อท่า: `u32 0, name[12], 4B, u32, u32 n, n × 15×i16`
- **`.csp`:** `u32 count, count × (u32 offset, u32 0)` · แต่ละรายการ: `u32 0, u32 k, k × u32 item_id` แล้วตามด้วย `.spr`
- **`.cmo`:** `u32 count` แล้วเรียงต่อกัน: `u32 idx, u32 k, k × u32 item_id, .mot` (ไฟล์ใหม่มี u32 แทรก, ไฟล์เก่าไม่มี prefix)
- **`.bg`:** byte0 = 3/4 (16/32-bit) · `u16 w` @0x0F · `u16 h` @0x11 · พิกเซล @27
- **`.til`:** มี image block แบบเดียวกับ `.spr` อยู่ 1 block (1024²) หรือหลาย block (256²)
- จับคู่ `.csp` ↔ `.cmo` ด้วย **item_id** (จำนวนรายการไม่เท่ากันเสมอ)
