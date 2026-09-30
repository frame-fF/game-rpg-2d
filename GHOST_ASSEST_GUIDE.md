# คู่มือใช้ Ghost Assets กับโปรเจกต์ Godot ใหม่

เอกสารนี้อ่านจบแล้วทำได้เลย ไม่ต้องรู้ประวัติการแกะไฟล์ ไม่ผูกกับโปรเจกต์เก่า
ตัวอย่างโค้ดทั้งหมดเป็น **Godot 4.x (GDScript)**

# ⚠️สำคัญ⚠️

ห้ามแก้ไขเปลี่ยนแปลงทุกอย่างใน Ghost Assets **`C:\Users\fF\Desktop\Ghost Assets`**
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
11.5 [ด่าน](#115-ด่าน-_stages)
12. [เสียง](#12-เสียง) · [12.5 ตารางข้อมูลเกม](#125-ตารางข้อมูลเกม-_tables) · [12.6 สคริปต์ NPC / บทพูด](#126-สคริปต์-npc--บทพูด-_scripts)
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
| `_items.json` | **ไอเทม 11,792 ชิ้น: ชื่อ + สเตตัส + ราคา + ไอคอน + ชิ้นที่ใส่** รวมไว้ในไฟล์เดียว (ดูหัวข้อ 4.1) | ฐานข้อมูลไอเทมพร้อมใช้ |
| `_tables/` | ตารางข้อมูลเกม 93 ตาราง เป็น `.csv` (เปิดใน Excel ได้) + `.json` (ดูหัวข้อ 12.5) | สกิล เควส NPC ร้านค้า คราฟต์ แผนที่ ข้อความ |
| `_tables_extra/` | ตารางเสริม: สกิล 577 ตัว (ชื่ออังกฤษ + ค่าทุกเลเวล), เงื่อนไขเควส 2,003 เควส, รายชื่อมอน 551 ตัว (ดูหัวข้อ 12.5.1) | สกิล เควส |
| `_tables_kr/` | ตาราง 94 ตัวจาก**ไคลเอนต์เกาหลี** (`C:\Games\GHOSTONLINEZ_OBT`) มี `tb_mob`, `tb_exp`, `tb_Mob_Drop` ที่ไคลเอนต์ไทยว่าง (ดูหัวข้อ 12.5.2) | สเตตัสมอน EXP ของดรอป |
| `_monsters.json` | **มอนสเตอร์ 442 ตัว: สเตตัส + รูป + ของดรอป** รวมไว้ในไฟล์เดียว (ดูหัวข้อ 12.5.2) | ทำมอนสเตอร์ |
| `_stages/` | **ด่าน 1,297 ด่าน**: พื้น ประตูวาร์ป จุดเกิด วัตถุที่วาง ชั้น parallax (ดูหัวข้อ 11.5) | ทำด่าน |
| `_scripts/` | **สคริปต์ NPC 934 ไฟล์ + บทพูด 42,515 บรรทัด** (ดูหัวข้อ 12.6) | บทสนทนา เควส |
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
| `raw` | ค่าดิบ 15 ช่อง: `[0]=frame [1]=delay [2]=x [3]=y [5]=layer [14]=sound` · **`[10]=frame [11]=x [12]=y [13]=layer` = สไปรต์ชิ้นที่สองของชิ้นเดียวกัน** (`[10] = -1` คือไม่มี) เช่นผมยาวด้านหลังตัว (layer −8) อาวุธอีกครึ่ง (layer −2) · `[4], [6..9]` ยังไม่รู้ | ✅ ชิ้นที่สองทดสอบแล้ว |

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

### 4.1 `_items.json` — ไอเทมพร้อมใช้ (ใช้ไฟล์นี้เป็นหลัก)

รวม `tb_Item` (ชื่อ/สเตตัส/ราคา) กับ `_item_index.json` (รูป) ไว้แล้ว มี 11,792 ชิ้น ในนั้นมีไอคอน 10,675 ชิ้น และมีชิ้นส่วนที่ใส่บนตัวได้ 4,901 ชิ้น

```json
{"id": 8110011, "name": "무사평복(남)",
 "icon": "OBJ/Item/dp_dress/000_무사평복_남",
 "part": "Avatar/avatar_dress/002_d_m_m_001",
 "stats": {"nSex": 1, "nLevel": 1, "nDefence": 3, "nEnchant": 10, "nPrice": 800, "nTrade": 1, "nOverlap": 1, "nInventory": 1, "nSlotPosition": 1}}
```

- `icon` / `part` = path ใน `Ghost Assets` (`null` = ไม่มี) · `part` เลือกไฟล์รุ่นใหม่ (`Avatar_*`) ให้แล้ว
- `stats` เก็บเฉพาะค่าที่ไม่ใช่ 0 (ความหมายของแต่ละคอลัมน์ดูหัวข้อ 12.5)
- **ชื่อไอเทมเป็นภาษาเกาหลี** (ไฟล์ไคลเอนต์ไทยก็เก็บชื่อไอเทมเป็นเกาหลี) ต้องแปลเองหรือตั้งชื่อใหม่ ส่วนข้อความอื่นในเกม (สกิล เควส NPC แผนที่) เป็นภาษาไทย

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
## Each frame can draw TWO sprites per part: the main one (frame/x/y/layer) and a second one
## from raw[10..13] (frame, x, y, layer) — e.g. back hair behind the body, the far side of a weapon.

signal motion_finished(motion: StringName)

## Seconds per Ghost "delay" tick. Unknown in the original engine — tune by eye.
@export var tick_sec: float = 1.0 / 30.0

var motion: StringName = &"STAND_1"
var looping := true
var _parts: Dictionary = {}    # slot -> GhostPart
var _sprites: Dictionary = {}  # slot -> [main Sprite2D, second Sprite2D]
var _frame := 0
var _elapsed := 0.0
var _done := false


func set_part(slot: StringName, part: GhostPart) -> void:
	if part == null:
		_parts.erase(slot)
		if _sprites.has(slot):
			for s in _sprites[slot]:
				s.queue_free()
			_sprites.erase(slot)
		return
	_parts[slot] = part
	if not _sprites.has(slot):
		var pair: Array[Sprite2D] = []
		for i in 2:
			var sprite := Sprite2D.new()
			sprite.centered = false
			add_child(sprite)
			pair.append(sprite)
		_sprites[slot] = pair
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


func _apply() -> void:
	for slot in _parts:
		var part: GhostPart = _parts[slot]
		var main: Sprite2D = _sprites[slot][0]
		var second: Sprite2D = _sprites[slot][1]
		var frames: Array = part.frames_of(motion)
		if _frame >= frames.size():  # this part has no such motion / fewer frames
			main.visible = false
			second.visible = false
			continue
		var f: Dictionary = frames[_frame]
		var raw: Array = f["raw"]
		_place(main, part, int(f["frame"]), int(f["x"]), int(f["y"]), int(f["layer"]))
		_place(second, part, int(raw[10]), int(raw[11]), int(raw[12]), int(raw[13]))


@warning_ignore("integer_division")
func _place(sprite: Sprite2D, part: GhostPart, index: int, x: int, y: int, layer: int) -> void:
	var tex: Texture2D = part.texture(index) if index >= 0 else null
	sprite.visible = tex != null
	if tex == null:
		return
	sprite.texture = tex
	sprite.offset = Vector2(x - tex.get_width() / 2, y - tex.get_height() / 2)
	sprite.z_index = layer
```

> ⚠️ **ต้องวาดสไปรต์ชิ้นที่สองด้วย** (`raw[10..13]`) ผมยาว 558/602 ชิ้น, หมวก 1,102/1,194, อาวุธ 897/1,252, อาวุธเสริม 265/324 และตา 265/745 ใช้ชิ้นที่สอง ถ้าไม่วาด ผมยาวด้านหลังหาย และอาวุธอีกครึ่งหาย (ตรวจด้วยการประกอบรูปแล้ว: `_tools/paperdoll2.png` คอลัมน์ซ้ายไม่วาดชิ้นที่สอง คอลัมน์ขวาวาด)

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

### 7.1 ความครบของชิ้นส่วนเทียบกับตัวละคร (ตรวจจากข้อมูลจริง)

ตัวละคร (`avatar_skin`, 28 สีผิว) มีครบ 32 ท่า และ**ทุกสีผิวใช้ท่าชุดเดียวกัน** (จำนวนเฟรมเท่ากันทุกท่า) ทุกชิ้นมี `_motion.json` ครบ

ตัวเลขด้านล่าง**ไม่นับซ้ำ** (ไฟล์รุ่นเก่า `dress`/`weapon` กับรุ่นใหม่ `avatar_dress`/`Avatar_weapon` มีชิ้นเดียวกันอยู่ทั้งสองไฟล์ นับชิ้นละครั้ง)

**ก) ท่า `ATTACK_5-7`** (ท่าที่เกมเพิ่มภายหลัง)

| ชิ้น | ขาดจริง | คิดเป็น item ID |
|---|---|---|
| ชุด | **216 ชิ้น** อยู่ในไฟล์ `avatar_dress` ไฟล์เดียว (216/380) · ไฟล์ชุดใหม่อื่นมีครบ | 506 จาก 2,898 ID (~17%) |
| อาวุธ | **273 ชิ้น** (273/763 ใน `Avatar_weapon`) | 600 จาก 1,487 ID (~40%) |

ของยุคแรกทำไว้ก่อนเกมเพิ่มท่าโจมตี 5–7 ถ้าเกมใช้แค่ `ATTACK_1-4` ไม่ต้องสนเรื่องนี้ ถ้าจะใช้ `ATTACK_5-7` ให้เลือกชุดจากไฟล์ใหม่และอาวุธที่มีท่านี้ (`part.motions.has(&"ATTACK_5")`) หรือให้ถอยไปใช้ `ATTACK_1-4` แทน

**ข) ท่าอื่นทั้งหมด (ไม่นับ `ATTACK_5-7`)** เทียบจำนวนเฟรมกับตัวละคร

| ชิ้น | ชิ้นที่ไม่ซ้ำ | ใช้ได้ครบทุกท่า | ที่มีปัญหา |
|---|---|---|---|
| **หมวก** | 803 | **100%** | — |
| **ผม** | 320 | **100%** | 1 ชิ้นขาดท่าเสริม |
| **ผ้าคลุม** | 414 | 97% | 11 ชิ้น**มีเฟรมเกิน** (ไม่เสียหาย ส่วนที่เกินไม่ได้ใช้) |
| **ชุด** | 1,802 | 93% | ~80 ชิ้นมีเฟรมน้อยกว่าในท่า `STICK`/`SCREAM`/`STRETCH`, 40 ชิ้นใน `ATTACK_4` |
| **อาวุธ** | 747 | 89% | ~70 ชิ้นใน `STICK`, 59 `SCREAM`, 49 `STRETCH`, 36 `ATTACK_3`, 28 `DEAD_1`, 11 `ATTACK_4`/`UPPER` |

- **ท่าที่ใช้บ่อย ใช้ได้ทุกชิ้น:** ยืน เดิน วิ่ง กระโดด `ATTACK_1-2` ร่ายเวท โดนตี ป้องกัน
- **ท่าที่มีปัญหาส่วนใหญ่เป็นท่าเสริม:** `STICK` (เกาะหรือปีน), `SCREAM` (ตะโกน), `STRETCH` (บิดขี้เกียจ) มีท่าต่อสู้ปนอยู่บ้าง: `ATTACK_3`/`4`, `DEAD_1` เฉพาะอาวุธบางชิ้น
- **ผลกับโค้ดในคู่มือ:** ชิ้นที่เฟรมน้อยกว่าตัวละคร `Paperdoll` จะซ่อนชิ้นนั้นในเฟรมที่เกิน ชุดหรืออาวุธจะหายไปแวบหนึ่งช่วงท้ายของท่า
  - ทางเลือก (ยังไม่ได้ทำ): ให้ชิ้นนั้นค้างอยู่ที่เฟรมสุดท้ายของตัวเองแทนการซ่อน แต่ยังไม่ได้ยืนยันว่าเกมต้นฉบับทำแบบไหน
- **อาวุธหาย ~20% ของเฟรม:** เป็นความตั้งใจ (ซ่อนอาวุธบางจังหวะ) ไม่ใช่ข้อมูลหาย
- ตรวจด้วย `_tools/audit4.py` (ATTACK_5-7) และ `_tools/audit5.py` (ท่าอื่น)

### 7.2 สกิล เอฟเฟกต์ ไอคอน — มีอะไร ขาดอะไร

| เรื่อง | สถานะ | แหล่ง |
|---|---|---|
| ข้อมูลสกิล (ชื่อ คำอธิบาย ค่าทุกเลเวล) | ✅ | `tb_skill` (ไทย, 520) + `tb_skilllevel` + `_tables_extra/skill` (อังกฤษ, 577) |
| สกิล → เอฟเฟกต์ | ✅ `tb_skilleffect.csv`: `nID` = รหัสสกิล, `nAttackEffectID1/2` = รหัสเอฟเฟกต์ | 639 สกิลมีเอฟเฟกต์ |
| เอฟเฟกต์ → รูป + ท่า | ✅ **ครบทั้ง 559 เอฟเฟกต์** หาโฟลเดอร์จากรหัสใน `_item_index.json` (เลือก path `OBJ/Effect/...` ที่ไม่มี `_2D`) | เช่น `1201` → `OBJ/Effect/attack/171_attack_1201` |
| เสียงเอฟเฟกต์ | ⚠️ 285/559 | `tb_SkillSound.csv` |
| ไอคอนสกิล | ⚠️ มีรูป 540 ไอคอน (`image/icon/Icon_Skill/NNN.png`, 34×34) แต่ **ไม่มีข้อมูลว่าไอคอนไหนของสกิลไหน** เทียบลำดับกับ `tb_skill` ตรงบางตัว (0 = วิชาตัวเบา, 3 = ฝ่ามือวายุ, 10 = เพิ่มพลังโจมตี) แต่ไม่ตรงทุกตัว → จับคู่เองด้วยตา | |
| สกิลใช้ท่าตัวละครท่าไหน | ❌ **ไม่มีในไฟล์** (น่าจะอยู่ในตัวโปรแกรมเกม) → กำหนดเอง: สกิลโจมตีระยะใกล้ใช้ `ATTACK_1-4`, สกิลเวท/ยิงใช้ `SPELL_1-3`, บัฟใช้ `SCREAM_1`, โจมตีขึ้นใช้ `UPPER_1-2` | |
| จังหวะตีโดน (เฟรมไหน) | ❌ ไม่มี → กำหนดเอง (เช่นเฟรมกลางของท่าโจมตี) | |

**วางเอฟเฟกต์ตรงไหน** (ทดสอบด้วยรูป `_tools/effect_test.png`):
- ใช้จุดยึดเดียวกับตัวละคร (เท้า) และสูตรเดียวกัน `(x - w/2, y - h/2)`
- **เอฟเฟกต์ที่อยู่บนตัว** เช่น 1324 (ตัวอักษร 梅花 เหนือหัว + ประกายบนตัว), 1326 (รอยฟันรอบตัว): ตำแหน่งถูก
- **กระสุน/ลูกพลัง** (เช่น 1201 ฝ่ามือวายุ) กับ**ระเบิดที่เป้า** (1330, 1476): ข้อมูลวางไว้ที่จุดยึด ต้องให้โค้ดเกมย้ายเอง เช่นให้กระสุนเริ่มที่ความสูงมือแล้ววิ่งไปข้างหน้า หรือให้ระเบิดเกิดที่ตำแหน่งศัตรู
- **เอฟเฟกต์ที่มีพื้นหลังสีดำ** ใส่ `CanvasItemMaterial` → `blend_mode = BLEND_MODE_ADD`
- **ทิศ:** ถ้าตัวละครหันขวา (`scale.x = -1`) ให้กลับเอฟเฟกต์ด้วย วาง node เอฟเฟกต์เป็นลูกของ Paperdoll หรือกลับ `scale.x` เหมือนกัน

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
- ชื่อไฟล์บอกชุด: `45_0.png` กับ `45_0_s.png` เป็นของชุด 45 ทั้งคู่ (`_s` เป็นรูปขนาดเล็กกว่า) ด่านไหนใช้ฉากหลังไหน ดูจาก `background` ใน `_stages/*.json` เช่น `t1_s1` ใช้ `Back/t11_2_s`
- ขนาดมีหลายแบบ: 256², 512², 800×600, 1280×1024
- ใช้ `Parallax2D` (Godot 4.3+) หรือ `ParallaxBackground` + `ParallaxLayer`:
  - ชั้นไกล: `scroll_scale = Vector2(0.2, 0.2)`, ชั้นกลาง: 0.5
  - ถ้าให้ภาพต่อกันแนวนอน ตั้ง `repeat_size.x = ความกว้างรูป`
- ตั้ง `z_index` ให้ติดลบมากๆ (เช่น -100) หรือวางใน `CanvasLayer` ที่ `layer = -1` จะได้อยู่หลังตัวละครเสมอ

### พื้น `Tile/*.png`
- `t1_1.png`, `t8_1.png` ฯลฯ เป็น **atlas 1024×1024 แบ่งเป็นช่อง 32×32 px** (32×32 = 1,024 ช่อง) เลขช่อง = `แถว × 32 + คอลัมน์` เป็นเลขเดียวกับที่ `.map` อ้างถึง (ดูหัวข้อ 11.5)
- `_0_00.png`, `t14_2_00.png` … เป็น atlas 256×256 หลายแผ่นจากไฟล์เดียว
- ใช้กับ `TileMapLayer` ได้ตรงๆ: สร้าง `TileSet` แบบ `tile_size = 32×32` แล้วเพิ่ม atlas source จาก PNG ช่อง (x, y) ใน Godot = (`index % 32`, `index / 32`)

---

## 11.5 ด่าน (`_stages/`)

แกะจาก `data/Project/*.prj` + `data/Map/*.map` ได้ **1,297 ด่าน** เป็น JSON ด่านละไฟล์ (`_stages/t1_s1.json` …) ดูรูปตัวอย่างที่ประกอบแล้วได้ที่ `_stages/_preview/t1_s1.png` (หมู่บ้าน 청음관)

**ชื่อไฟล์:** `t<ธีม>_s<ด่าน>` เช่น `t1_s1` = ธีม 1 ด่าน 1 · ชื่อด่านภาษาไทยดูได้ใน `_tables/tb_Map.csv` (`nTheme`, `nStage`, `szStageName`, `szBGM1`)

```json
{
 "name": "청음관",
 "background": "Back/t11_2_s",            ← ภาพฉากหลัง (Back/*.png)
 "tileset": "Tile/t1_1",                  ← atlas ของพื้น (Tile/*.png)
 "map": "t1_s1.map",                      ← ไฟล์ grid พื้น (อ่านด้วย maprender.py)
 "portals": [
  {"name": "청음관의원내부", "rect": [5013, 1077, 5118, 1120],
   "target": "t1_s41", "target_pos": [755, 600]}          ← เดินเข้ากรอบนี้ → วาร์ปไปด่าน t1_s41 จุด (755, 600)
 ],
 "spawns": [{"a": 1, "b": 1, "x": 1200, "y": 1200}, ...], ← จุดเกิด/เกิดใหม่ของผู้เล่น
 "objects": [                                             ← รายการวัตถุที่ใช้ในด่าน
  {"id": 3140701, "name": "나무1", "sprite": "OBJ/Object/tree_14", "motion": "OBJ/Object/tree_14"}
 ],
 "layers": [                                              ← วัตถุที่วางจริง แยกเป็นชั้น
  {"width": 4000, "height": 1920, "items": [...]},        ← ชั้น parallax (มี width = กว้างเท่านี้ เลื่อนช้ากว่าฉาก)
  {"width": null, "height": null, "items": [              ← ชั้นหลักของด่าน (null = ใช้ขนาดแผนที่)
    {"name": "나무1", "object_id": 3140701, "x": 1840, "y": 1676, "scale": 1.2, "flag": 1}
  ]}
 ]
}
```

**พื้น (`.map`):**
- grid ขนาด `w × h` ช่อง ช่องละ **32 px** (เช่น `t1_s1` = 180×60 = 5,760×1,920 px)
- แต่ละช่องมี 2 ชั้น (หน้า/หลัง) ชั้นละไม่เกิน 16 tile ซ้อนกัน อ่านด้วย `_tools/maprender.py` (ฟังก์ชัน `cells()` ให้ `(x, y, layer, [tile index…], attr)`)
- ไฟล์: `u32 w, u32 h` แล้วเก็บ**ทีละคอลัมน์**: คอลัมน์ละ `[ชั้น 0: h ช่อง][ชั้น 1: h ช่อง]`, ช่องละ 36 byte = `16 × u16 tile` (`0xFFFF` = ว่าง) + 4 byte attribute (ยังไม่รู้ความหมาย)

**การวางวัตถุ:** `x, y` ใช้หลักเดียวกับตัวละคร (จุดยึด) → วาดเฟรมแรกของท่าแรกใน `_motion.json` ของ sprite นั้นที่ `(x + fx - w/2, y + fy - h/2)` แล้วคูณ `scale` ทดสอบแล้ว: บ้าน ต้นไม้ สะพาน วางบนพื้นตรงตำแหน่ง

**เอาเข้า Godot:**
1. พื้น → `TileMapLayer` (tile 32×32) วนทุกช่องจาก `.map` แล้ว `set_cell(Vector2i(x, y), 0, Vector2i(t % 32, t / 32))` ทำ 2 `TileMapLayer` สำหรับ 2 ชั้น
2. วัตถุชั้นหลัก → `GhostPart` + `Paperdoll` (หัวข้อ 6) หรือ `Sprite2D` วางตาม `x, y, scale`
3. ชั้น parallax → `Parallax2D` ชั้นละ node, `scroll_scale.x ≈ layer.width / ความกว้างแผนที่`
4. ประตู → `Area2D` ขนาด `rect` เมื่อผู้เล่นเข้า → โหลดด่าน `target` แล้ววางผู้เล่นที่ `target_pos`
5. เอฟเฟกต์ที่มีพื้นหลังสีดำ (ไฟสีฟ้า วงกลมดำในรูป preview) เป็นแบบ **additive blend** → ใส่ `CanvasItemMaterial` ตั้ง `blend_mode = BLEND_MODE_ADD` สีดำจะหายไป

**ข้อจำกัด:**
- **collision ของพื้นไม่มี:** ต้องสร้างเองจากช่องที่มี tile เช่นใส่ physics ใน TileSet หรือใช้ `.att` ที่ยังไม่ได้แกะ
- **จุดเกิดมอนสเตอร์ไม่มี:** อยู่ที่เซิร์ฟเวอร์
- **ค่า `width` ของชั้น parallax บางด่านอาจผิด:** ด่านที่มีข้อมูลพิเศษก่อนตารางวัตถุ ใช้วิธีสแกนหาเร็คคอร์ดแทน ตำแหน่งวัตถุถูก แต่การแบ่งชั้นอาจเพี้ยน
- **แกะไม่ได้ 8 ด่าน:** ไฟล์เล็กผิดปกติหรือด่านอีเวนต์ที่ไม่มีวัตถุ (`t16_s2`, `t201_s1`, `t201_s2`, `t202_s1`, `t204_s2`, `t39_s2`, `t42_s41`, `t500_s1`)
- **ประตู 96 จาก 1,811 อัน** ชี้ไปด่านที่ไม่มีในไคลเอนต์แล้ว

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
- รหัส `sound` ใน `_motion.json` **ยังจับคู่กับไฟล์ไม่ได้** ให้ผูกเสียงกับท่าเอง เช่น "เล่น `03_Attack.wav` ตอนเริ่ม `ATTACK_1`"
- **ตารางที่ช่วยได้:**
  - `_tables/tb_SkillSound.csv`: เอฟเฟกต์สกิล → ไฟล์เสียง เช่น `1001` → `sound/Cha_Effect/Cha_MJ_width.wav` (เอฟเฟกต์ `1001` คือ `OBJ/Effect/attack/003_attack_1001`)
  - `_tables/tb_Map.csv`: ด่าน → เพลง BGM เช่น "ด่านชิงอิน" → `BGM_chungumgwan.mp3`

---

## 12.5 ตารางข้อมูลเกม (`_tables/`)

แกะจาก `zThailand/chart/*.tbl` ได้ 93 ตาราง แต่ละตารางมีทั้ง `.csv` (UTF-8, เปิดใน Excel ได้) และ `.json` (array ของ object) ชื่อคอลัมน์ขึ้นต้นตามชนิดข้อมูล: `n` = ตัวเลข, `sz` = ข้อความ, `e` = enum, `b` = 0/1

**ตารางสำคัญ:**

| ตาราง | แถว | คอลัมน์หลัก | ใช้ทำ |
|---|---|---|---|
| `tb_Item` | 11,792 | `nID, szName, eJob, nSex, nLevel, nType, nPAttack, nMAttack, nPRange, nMRange, nDefence, nAttackSpeed, nEnchant, nPrice, nStrangth, nDexterity, nConstitution, nIntellect, nDodge, nHitPoint, nSpiritPoint, nCritical, nOverlap, nSlotPosition, szTooltip` | ไอเทม (รวมใน `_items.json` แล้ว) |
| `tb_skill` | 520 | `nID, szName, mClass, mJob, nWeaponType, bIsActive, nTargetCount, nRespellTime, nRangeType, szSkillInfo` | รายชื่อสกิล (ภาษาไทย) |
| `tb_skilllevel` | 15,746 | `nSkillNo, nLevel, nSpendHP, nSpendSP, nDurationTime, nAttackRange, nAttrID1-7, nValue1-7` | ค่าสกิลแต่ละเลเวล |
| `tb_LearnSkill` | 341 | | เงื่อนไขเรียนสกิล |
| `tb_JobBase`, `tb_JobGrowth` | 13 / 131 | `szName, eClass, eJob, nGlowthHP, nGlowthSP, nGlowthAtt, nGlowthDef` | อาชีพ + ค่าที่เพิ่มต่อเลเวล |
| `tb_listquest` | 2,831 | `nStartLevel, nEndLevel, eJob1-6, szQuestName, szQuestText1-4, szQuestInfo1-5, nR_Exp, nR_Money, nR_ItemID1-4, nR_Count1-4` | เควส + บทพูด + รางวัล |
| `tb_letterquest` | 201 | | เควสจดหมาย |
| `tb_npc` | 815 | `nID, scNPCName, bShowMinimap` | ชื่อ NPC |
| `tb_NpcStoreL`, `tb_NpcStoreItem` | 104 / 3,085 | `nStoreID, nItemID, nMoney, nMoneyType` | ร้านค้า NPC ขายอะไร ราคาเท่าไร |
| `tb_RecipeList` | 985 | `szRecipeName, nResult, nResultCount, nMaterialID1-9, nMCount1-9` | สูตรคราฟต์ |
| `tb_UpgradeEquip`, `tb_upgradeitem`, `tb_EquipRefine`, `tb_enchantacc` | | | ตีบวก / อัปเกรด |
| `tb_Socket` | 350 | | ช่องใส่หิน |
| `tb_SetEquipItem`, `tb_SetEquipItemValue` | 1,403 / 685 | `szSetName, eSetBenefit, nSetValue, szSetBenefitText1-2` | โบนัสเซ็ตอุปกรณ์ |
| `tb_Map` | 1,120 | `nTheme, nStage, szStageName, szBGM1-3` | ชื่อด่าน (ไทย) + เพลง |
| `tb_Worldmap`, `tb_themestage` | 569 / 820 | | แผนที่โลก |
| `tb_SkillSound` | 442 | `nSkillEffectID, nSkillSndID, szSkillSndDir` | เสียงของเอฟเฟกต์สกิล |
| `tb_String` | 7,099 | `nMSGID, szMSG, szStringDefine` | ข้อความระบบทั้งหมด (ไทย) |
| `tb_GameTip`, `tb_HelpSay`, `tb_FortuneText` | | | ข้อความทิป / ช่วยเหลือ / ดูดวง |
| `tb_Title`, `tb_TitleNickName` | | | ฉายา |
| `tb_Emoticon` | 52 | | อีโมติคอน |
| `tb_giftpocket`, `tb_PocketInfo`, `tb_SelectBox` | 22,111 / 4,500 | | กล่องสุ่ม / ของในกล่อง |
| `tb_FilterName`, `tb_FilterChat` | 6,722 | | คำหยาบที่ห้ามใช้ |

**ตารางว่าง (ไม่มีข้อมูลในไคลเอนต์):**
- `tb_Mob`, `tb_Exp`, `tb_Mob_Drop` ในไคลเอนต์ไทยว่าง แต่**ไคลเอนต์เกาหลีมีข้อมูลครบ** → ใช้ `_tables_kr/` และ `_monsters.json` (หัวข้อ 12.5.2)

**ความหมายคอลัมน์ที่ยังไม่ชัวร์:** ค่า enum (`eJob`, `nType`, `nSlotPosition`, `nAttribute` ฯลฯ) เป็นตัวเลข ไม่มีตารางบอกความหมาย ต้องเดาจากข้อมูล เช่น ใน `tb_Item` ชุดมี `nSlotPosition = 1`, ผ้าคลุม = 4, ยันต์ = 17 และ `nSex`: 1 = ชาย

### 12.5.1 ตารางเสริม (`_tables_extra/`) — แยกไว้เพราะอาจซ้ำกับ `_tables/`

| ไฟล์ | มาจาก | เนื้อหา | ซ้ำกับ |
|---|---|---|---|
| `mob_list` | `zThailand/table/mob.mdd` | รหัสมอนสเตอร์ 551 ตัว (เช่น `1000301`, `1001201`) | `_tables_kr/tb_mob` (442 ตัวพร้อมสเตตัส) |
| `skill` | `zThailand/table/skill.skl` | **สกิล 577 ตัว ชื่อภาษาอังกฤษ + คำอธิบาย + ค่าทุกเลเวล** (สูงสุด 40 เลเวล) | `tb_skill` (ชื่อไทย) + `tb_skilllevel` |
| `skillcnt` | `zThailand/table/skillcnt.cnt` | 825 คู่ `(id, value)` ยังไม่รู้ความหมาย (id 1–10, 101–110 … value 0–6) | — |
| `qt` | `zThailand/script/qt.tab` | **เงื่อนไขเควส 2,003 เควส**: ฆ่ามอน (436 เควส), เก็บของ (762), คุยกับ NPC (216), ของรางวัล (563) | `tb_listquest` (มีบทพูด/รางวัล แต่ไม่มีเงื่อนไข) |

ทุกไฟล์มีทั้ง `.json` (ข้อมูลเต็ม) และ `.csv` (สรุป เปิด Excel ได้)

**`skill.json`:**
```json
{"id": 6, "name": "EnergyBlast",
 "attributes": [{"attr_id": 12, "per_level": [230, 320, 415, 520, 640, 775, 925, 1100, 1300, 1600]},
                {"attr_id": 13, "per_level": [230, 320, ...]},
                {"attr_id": 15, "per_level": [2, 2, 2, 2, 2, 3, 3, 3, 3, 3]}],
 "description": "Instantly explode all the energy that you have accumulated with your attacks."}
```
- `per_level[0]` = เลเวล 1 ตัดเลเวลที่เป็น 0 ท้ายๆ ออกแล้ว
- `attr_id` = ชนิดค่า (ดาเมจ ระยะ คูลดาวน์ ฯลฯ) ยังไม่มีตารางบอกความหมาย ที่ใช้บ่อย: 1, 15, 12, 18, 13, 19 ลองเทียบกับ `nAttrID` ใน `tb_skilllevel`
- 121 สกิลชื่อ `[미번역]` ("ยังไม่แปล") เป็นอย่างนี้มาจากไฟล์ต้นฉบับ

**`qt.json`:**
```json
{"id": 8, "kill_monsters": [[1001201, 10]], "collect_items": [], "meet_npcs": [],
 "start_items": [], "step_items": [], "values": [1800, 500, 1, 0], "reward_items": []}
```
- `kill_monsters` = `[รหัสมอน, จำนวน]` (รหัสตรงกับ `mob_list`) · `collect_items` = `[item ID, จำนวน]` · `meet_npcs` = รหัส NPC ที่ต้องไปคุย · `reward_items` = `[item ID, จำนวน]` · `start_items` = ของที่ได้ตอนรับเควส (เดา)
- ⚠️ `values` (น่าจะเป็น EXP/เงิน/ชื่อเสียง) กับเลข `id` **ไม่ตรงกับ `tb_listquest`** ทุกเควส อาจเป็นข้อมูลรุ่นเก่าหรือใช้ลำดับเควสคนละแบบ ใช้เป็นแนวทางออกแบบเงื่อนไขเควสได้ แต่อย่าถือว่าตรงกับ `tb_listquest` แบบ 1:1
- ฟิลด์ `f1`–`f5`, `flag`, `a`, `unknown_list`, `extra_ids` ยังไม่รู้ความหมาย

### 12.5.2 มอนสเตอร์ + EXP จากไคลเอนต์เกาหลี (`_tables_kr/`, `_monsters.json`)

ไคลเอนต์ไทยไม่มีสเตตัสมอน/EXP/ของดรอป (ตารางว่าง) แต่**ไคลเอนต์เกาหลี** `C:\Games\GHOSTONLINEZ_OBT` (Ghost Online Z, รูปแบบไฟล์เดียวกัน) มีครบ แยกไว้ที่ `_tables_kr/` (94 ตาราง ข้อความเป็นเกาหลี)

| ตาราง | แถว | เนื้อหา |
|---|---|---|
| `tb_mob` | 442 | `nID, szMobName, nMobLv, nMobEXP, nMobHP, nMobAtt1/2, nMobAtt1/2Range, nMobAtt1/2Spd, nMobCrashAtt` (ดาเมจเวลาชน), `nMobDefence, nMobMoveSpd, nRegenTime, nMobMoney, nMoneyDropPer, nResist*` (ต้านธาตุ) |
| `tb_exp` | 200 | `nLevel, nLevelExp` EXP ที่ต้องใช้ต่อเลเวล (1 → 10, 2 → 25, 3 → 65 …) |
| `tb_Mob_Drop` | 649 | `nExorcizeID` (= รหัสมอน) + `nDrop1..N` (item ID) + `nDrop1..NPer` (โอกาส หน่วยน่าจะเป็น /10000) |

**`_monsters.json`** (รวมให้แล้ว):
```json
{"id": 1000301, "name_kr": "어인귀", "level": 3, "hp": 37, "attack1": 7, "attack1_range": 400,
 "touch_damage": 7, "defence": 2, "move_speed": 160, "exp": 14, "money": 14,
 "sprite": "OBJ/Monster/m000301",
 "drops": [{"item_id": 8510011, "item_name": "봉인상자", "rate": 4000}, ...],
 "raw": { ...ทุกคอลัมน์ของ tb_mob... }}
```
- **รหัสมอน → โฟลเดอร์รูป:** `"m" + รหัสตัดเลขตัวแรก` (`1000301` → `OBJ/Monster/m000301`) จับคู่ได้ **380/442** ตัว อีก 62 ตัวเป็น `null` (ชื่อโฟลเดอร์ไม่ตรงสูตร ต้องหาเอง)
- **ของดรอป:** 286 ตัวมีรายการดรอป ชื่อไอเทมมาจาก `_items.json` (บางตัวเป็น `null` คือไม่มีใน `tb_Item` ของไทย)
- **ชื่อมอนเป็นภาษาเกาหลี** ต้องแปลเอง
- **ค่าเป็นของเวอร์ชันเกาหลี:** ความยากหรือสมดุลอาจต่างจากไทยเล็กน้อย ใช้เป็นค่าตั้งต้นแล้วปรับเอง
- เพิ่มมอนสเตอร์ 3 ตัวที่มีแค่ในเกาหลีลงใน `OBJ/Monster/` แล้ว: `m004521`, `m004522`, `m004523`

**ไคลเอนต์เกาหลีเทียบกับไทย** (ตรวจแล้ว):
- **ชิ้นส่วนตัวละคร/เอฟเฟกต์:** ไทยมีมากกว่าทุกไฟล์ (เช่นผม +18, ชุด +16, หมวก +6, สีผิว +6) เกาหลีไม่มีชิ้นไหนที่ไทยไม่มี → **ใช้ของไทยต่อไป**
- **เอฟเฟกต์ความละเอียดต่ำ (`_2D`):** ไทยมี 13 ชุด เกาหลีไม่มี · `tb_skilleffect` ไทย 792 แถว เกาหลี 622
- **เกาหลีมีเพิ่ม:** ตารางมอน/EXP/ดรอปข้างบน, คลิป Flash 11 ไฟล์ (ไทยมี 2), ไฟล์แพตช์ `GHO_00/01.bin` (มีแค่ตารางและ UI ร้านค้า ไม่มีชุดหรือเอฟเฟกต์)

---

## 12.6 สคริปต์ NPC / บทพูด (`_scripts/`)

แกะจาก `.luc` (Lua 5.0 bytecode) ได้ **934 ไฟล์**:
- `zThailand/script/` (565 ไฟล์) **ภาษาไทย** เป็นชุดที่ไคลเอนต์ไทยใช้จริง
- `data/OBJ/NPC/` (369 ไฟล์) ชุดเก่า ส่วนใหญ่เป็นภาษาเกาหลี

| ไฟล์ | เนื้อหา | ใช้ทำ |
|---|---|---|
| `_scripts/_dialogue.json` | **บทพูดทั้งหมดแยกตาม NPC** (754 สคริปต์, 42,515 บรรทัด) | เอาไปทำระบบบทสนทนาได้เลย |
| `_scripts/_api.txt` | รายชื่อฟังก์ชันที่สคริปต์เรียกใช้ 265 ตัว เรียงตามจำนวนครั้ง | ดูว่าระบบ NPC ต้องรองรับอะไรบ้าง |
| `_scripts/<path>/npc_XXXXXX.json` | โครงสร้างสคริปต์: ฟังก์ชัน ตัวแปร ค่าคงที่ (ข้อความ ตัวเลข item ID) | ดูลำดับตรรกะของ NPC |
| `_scripts/<path>/npc_XXXXXX.luac` | bytecode ที่ซ่อมหัวไฟล์และถอดข้อความแล้ว (Lua 5.0 มาตรฐาน) | ถ้าอยากได้โค้ด Lua เต็ม ใช้ decompiler Lua 5.0 (เช่น `luadec` รุ่น 5.0) เปิดได้ |

**ชื่อไฟล์:** `npc_200003` = NPC รหัส 200003 (ตรงกับ sprite `OBJ/NPC/npc_200003`) ชื่อ NPC ดูได้ใน `_tables/tb_npc.csv`

**ตัวอย่างบทพูด (ไทย):**
```
"ถ้าเจ้าช่วยปราบ{0xFFFFFF00}หมีภูเขาแห่งบันไดฟ้าคำราม 60 ตัว{END}ข้าจะรวบรวมหนังมันมาทำเป็นชุด..."
"ขอบคุณมาก ทีนี่ก็โล่งใจแล้ว! นี่คือของตอบแทนเล็กๆ น้อยๆ โปรดรับไว้ด้วยเถอะ"
```
- `{0xAARRGGBB}ข้อความ{END}` = ข้อความสี → แปลงเป็น BBCode ของ `RichTextLabel`: `[color=#RRGGBB]ข้อความ[/color]`
- `PLAYERNAME` = ใส่ชื่อผู้เล่นแทน

**ฟังก์ชันที่ใช้บ่อย** (จาก `_api.txt`):

| ฟังก์ชัน | ครั้ง | ความหมาย |
|---|---|---|
| `QSTATE` | 924 | สถานะเควส |
| `NPC_SAY`, `NPC_QSAY` | 769 / 83 | NPC พูด / พูดเรื่องเควส |
| `CHECK_ITEM_CNT`, `CHECK_INVENTORY_CNT` | 597 / 316 | เช็คจำนวนไอเทม / ช่องว่างในกระเป๋า |
| `GET_PLAYER_LEVEL`, `GET_PLAYER_JOB1`, `GET_PLAYER_FACTION` | 557 / 79 / 40 | อ่านเลเวล อาชีพ ฝ่าย |
| `SET_QUEST_STATE`, `ADD_QUEST_BTN`, `SET_MEETNPC` | 454 / 413 / 231 | เปลี่ยนสถานะเควส / ปุ่มเควส / นับว่าคุยกับ NPC แล้ว |
| `ADD_SHOP_BTN`, `ADD_NEW_SHOP_BTN`, `ADD_STORE_BTN` | | ปุ่มร้านค้า / โกดัง |
| `NPC_WARP_THEME_*`, `ADD_NPC_WARP_INDUN_EXIT` | | วาร์ปไปธีมอื่น / ออกจากดันเจี้ยน |

**ข้อจำกัด:**
- **ข้อความหาย 1,153 บรรทัด:** เป็น `???` มาตั้งแต่ไฟล์ต้นฉบับ เพราะภาษาเกาหลีหายตอนบันทึกเป็นภาษาไทย กู้ไม่ได้
- **ยังไม่ได้แปลงเป็นโค้ด Lua ที่อ่านได้:** ต้องใช้ decompiler ภายนอก
- **1 ไฟล์เป็น Lua 5.1** (`npc_300120`) ไม่ได้แกะ

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
7. **ทำ ItemData** (หัวข้อ 9) จาก `_items.json` ซึ่งมีชื่อ สเตตัส ราคา ไอคอน และชิ้นที่ใส่ครบ
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
| รหัส `sound` ใน `_motion.json` → ไฟล์เสียง | ไม่รู้ (ไม่อยู่ในตารางที่แกะได้) | ผูกเสียงเอง (มีแค่เสียงสกิลใน `tb_SkillSound`) |
| ช่อง `raw[6..13]` | ไม่รู้ (น่าจะเป็นจุดปล่อยเอฟเฟกต์/กระสุน) | กำหนดจุดยิงเอง |
| hitbox ต่อเฟรม | มีในไฟล์ต้นฉบับ แต่ไม่ได้ export | ตั้ง collision เอง |
| ลำดับเฟรมปุ่ม UI (ปกติ/ชี้/กด) | เดา | เปิดดูก่อนใช้ |
| `.map` + `.prj` | ✅ **แกะแล้ว** → `_stages/` 1,297 ด่าน (8 ด่านไม่ได้) | — |
| attribute 4 byte ในแต่ละช่องของ `.map` | ไม่รู้ | collision ของพื้นต้องทำเอง |
| `.luc` (935) | ✅ **แกะแล้ว** → `_scripts/` 934 ไฟล์ (ข้อความ + โครงสร้าง, ยังไม่เป็นโค้ด Lua ที่อ่านได้) | ถ้าต้องการโค้ดเต็ม ใช้ decompiler Lua 5.0 กับ `.luac` |
| จุดเกิดมอนสเตอร์ | ไม่อยู่ในไคลเอนต์ | วางเอง |
| `.tbl` (93 ตาราง) | ✅ **แกะแล้ว** → `_tables/` | — |
| `qt.tab`, `mob.mdd`, `skill.skl`, `skillcnt.cnt` | ✅ **แกะแล้ว** → `_tables_extra/` (ความหมายบางฟิลด์ยังเดา) | — |
| สเตตัสมอนสเตอร์, ตาราง EXP, ของดรอป | ✅ **ได้จากไคลเอนต์เกาหลี** → `_tables_kr/`, `_monsters.json` (มอน 62 ตัวยังไม่รู้ว่าใช้รูปไหน) | — |
| `.etb` (23 ไฟล์ เช่น `mon_data.etb`, `pet.etb`) | เข้ารหัส และ `Game.exe` มีตัวกันโกง (XIGNCODE) | ส่วนใหญ่ซ้ำกับ `.tbl` ที่แกะแล้ว |
| `.att`, `.cob` | ไม่ได้แกะ | น่าจะเป็น collision ของพื้น |
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
| `tbl.py` | `zThailand/chart/*.tbl` → `_tables/*.csv` + `*.json` | `python tbl.py` |
| `build_items.py` | รวม `tb_Item` + `_item_index.json` → `_items.json` | `python build_items.py` (รันหลัง `tbl.py` และ `build_index.py`) |
| `stage.py` | `.prj` → `_stages/*.json` | `python stage.py` |
| `maprender.py` | อ่าน/วาด `.map` ด้วย tileset (มี `cells()` ไว้ใช้ต่อ) | `python maprender.py t1_s1.map t1_1.png` |
| `stage_render.py` | รูป preview ด่าน: พื้น + วัตถุ | `python stage_render.py t1_s1` |
| `luc.py` | `.luc` → `_scripts/*.json` + `.luac` มาตรฐาน | `python luc.py` |
| `dialogue.py` | สรุป `_dialogue.json` + `_api.txt` | `python dialogue.py` (รันหลัง `luc.py`) |
| `extra_tables.py` | `mob.mdd`, `skill.skl`, `skillcnt.cnt`, `qt.tab` → `_tables_extra/` | `python extra_tables.py` |
| `kr_export.py` | ตารางไคลเอนต์เกาหลี → `_tables_kr/` + มอนสเตอร์ 3 ตัวที่มีแค่ใน KR | `python kr_export.py` |
| `build_monsters.py` | รวม `tb_mob` + `tb_Mob_Drop` + ชื่อไอเทม + โฟลเดอร์รูป → `_monsters.json` | `python build_monsters.py` (รันหลัง `kr_export.py`, `build_items.py`) |

### รูปแบบไฟล์ต้นฉบับ (สรุป)
ทุกไฟล์เป็น little-endian ข้อความเป็น CP949 (เกาหลี)

- **`.spr`:** name 0x80 ×2 · `u32 frames` @0x100 · ต่อเฟรม: `u32 id`, `u32 n + n×16B rect`, `u32 m + m×16B rect`, block 16B (`01 03`=ARGB1555 / `01 04`=BGRA8888 … `00 ff 00 ff`), `u16 w, 2B, u16 h, 2B, u32 pixel_count`, พิกเซล (ใช้ w×h แรก)
- **`.mot`:** name 0x80 ×2 · `u32 motions` @0x100 · ต่อท่า: `u32 0, name[12], 4B, u32, u32 n, n × 15×i16`
- **`.csp`:** `u32 count, count × (u32 offset, u32 0)` · แต่ละรายการ: `u32 0, u32 k, k × u32 item_id` แล้วตามด้วย `.spr`
- **`.cmo`:** `u32 count` แล้วเรียงต่อกัน: `u32 idx, u32 k, k × u32 item_id, .mot` (ไฟล์ใหม่มี u32 แทรก, ไฟล์เก่าไม่มี prefix)
- **`.bg`:** byte0 = 3/4 (16/32-bit) · `u16 w` @0x0F · `u16 h` @0x11 · พิกเซล @27
- **`.til`:** มี image block แบบเดียวกับ `.spr` อยู่ 1 block (1024²) หรือหลาย block (256²)
- จับคู่ `.csp` ↔ `.cmo` ด้วย **item_id** (จำนวนรายการไม่เท่ากันเสมอ)
- **`.tbl`:** `"Ghost\0\0\0TH\0\0"` + วันที่ · `u32 ncol` @0x20 · `ncol × u32 type` · `u32 nrow` · ชื่อคอลัมน์ `ncol × (u16 len + ข้อความ)` · แล้วตามด้วยข้อมูลทีละแถว
  - ขนาดตาม type: 1=u8, 2=u8, 3=i16, 4=u16, 5=i32, 6=u32, 8=f32, 10=i64, 7=ข้อความ
  - ข้อความ = `u16 len` + byte ที่ **XOR 0x11 แล้วเก็บกลับด้าน** เป็น UTF-8 (ไทย/เกาหลี)
- **`.map`:** `u32 w, u32 h` · ต่อคอลัมน์: `[ชั้น 0 × h][ชั้น 1 × h]` ช่องละ 36B = `16 × u16 tile` + 4B attr · tile 32 px
- **`.prj`:** ชื่อ @0 · path bg @0x60, til @0xE0, map @0x160 (ช่องละ 0x80) · `u32 n` + รายชื่อ .spr · `u32 n` + รายชื่อ .mot · `u32 ntil, w, h` + til + map · `u32 nbg` + bg · `u32 n` + ประตู 160B (`name[0x80], x1,y1,x2,y2, theme, stage, tx, ty`) · `u32 n` + จุดเกิด 16B · `u32 n` + วัตถุ (name, id, spr, mot, ท้ายยาวไม่เท่ากันตามชนิด) · ตารางวาง: กลุ่ม `(n, w, h)` = parallax หรือ `(n)` = ชั้นหลัก, แต่ละรายการ 37B (`name[16], u32, u32 object_id, u8, f32 scale, i32 x, i32 y`)
- **`skill.skl`:** ช่องละ 32 byte · ช่องตัวเลข/ชื่อ = XOR `0xAA` จบด้วย `0x55` · คำอธิบาย = ข้อความธรรมดา 128 byte · 1 สกิล = `22 + 41 × nAttr` ช่อง
- **`skillcnt.cnt`:** ช่องละ 64 byte UTF-16LE, byte ที่ไม่ใช่ 0 ถูก XOR `0xAA` · **`mob.mdd`:** `u32 n` + `n × u32`
- **`qt.tab`:** `u16 n` · แต่ละเควส: `u16 id, u16, u16, i32, i16, u8 flag, u8 0x77, u8` + รายการนับจำนวน 6 ชุด (ขนาดรายการ 12, 12, 8, 4, 8, 4 byte) + `i32` + `4 × u32` + รายการ 8 byte + รายการ 4 byte
- **`.luc`:** Lua 5.0 bytecode ที่ตัดคำว่า `Lua` ออกจาก signature (`1B 50 …`) และทุกข้อความถูกเลื่อน: `ตัวจริง[i] = byte[i] − (i+1)` · opcode เป็นมาตรฐาน
