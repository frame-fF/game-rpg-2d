# Ghost Online Assets — สรุปการแกะไฟล์และการนำมาใช้ในโปรเจกต์

## 1. แหล่งที่มา

| แหล่ง | ที่อยู่ | หมายเหตุ |
|---|---|---|
| **GhostOnlineTH** (หลัก) | `C:\Games\GhostOnlineTH_Client` | ใหม่กว่า ข้อมูลเยอะกว่า (~9.3 GB) — ใช้เป็นแหล่งจริง |
| Soul Saver Online | `C:\Games\Steam\steamapps\common\SoulSaverOnline\data` | เอนจิน/ฟอร์แมตเดียวกัน ข้อมูลน้อยกว่า ใช้แค่รอบแรก ถูก Ghost ทับหมดแล้ว |

## 2. ผลลัพธ์: `C:\Users\fF\Desktop\Ghost Assets` (483,055 ไฟล์, 2.9 GB)

| โฟลเดอร์ | เนื้อหา | ไฟล์ |
|---|---|---|
| `Avatar/` | ชิ้นส่วนตัวละคร paperdoll: ตัว ผม ตา หน้า ชุด หมวก ผ้าคลุม อาวุธ ฯลฯ + `_motion.json` | 358,512 |
| `OBJ/` | มอนสเตอร์ (`Monster/`), NPC, ไอเทม/ไอคอน (`Item/`), เอฟเฟกต์ (`Effect/`), ตัวละครพื้นฐาน `boy`/`girl` | 111,595 |
| `zThailand/` | UI ทั้งหมด (`ui/common`, `ui/cashshop`, `ui/login` ฯลฯ) — ปุ่ม หน้าต่าง ตัวเลข | 8,586 |
| `sound/` | `.wav` 1,390 + `.mp3` 190 (copy ตรง) | 1,580 |
| `image/` | UI/ไอคอน/เคอร์เซอร์ | 1,727 |
| `Back/` | ภาพพื้นหลัง (parallax) เป็น PNG | 184 |
| `Tile/` | tileset เป็น PNG (ไฟล์หลาย atlas → `_00`, `_01`, …) | 120 |
| `UserData/GuildMark` | ตรากิลด์ `.bmp` | 552 |
| `gskeeper/`, `npc/` | อื่นๆ | 199 |

### โครงสร้างโฟลเดอร์ของสไปรต์

```
OBJ/Monster/m010005/            ← 1 ไฟล์ .spr = 1 โฟลเดอร์
    000.png 001.png ...         ← 1 เฟรม = 1 PNG (RGBA, พื้นโปร่งใส)
    _motion.json                ← ท่าทาง (ถ้ามี .mot คู่กัน)

Avatar/avatar_dress/            ← 1 ไฟล์ .csp = 1 โฟลเดอร์ (รวมหลายชิ้น)
    002_d_m_m_001/              ← <ลำดับในไฟล์>_<ชื่อชิ้น>
        000.png ...
        _motion.json            ← มี item_ids + ท่าทางของชิ้นนี้
```

## 3. `_motion.json` — ข้อมูลท่าทาง/ตำแหน่ง

```json
{
  "source": "avatar_dress.csp #2",
  "item_ids": [8110011, 18110011, 8150011],
  "motions": [
    {"name": "STAND_1", "frames": [
      {"frame": 0, "delay": 7, "x": -1, "y": -23, "layer": 6, "sound": 0, "raw": [/* 15 ค่า */]}
    ]}
  ]
}
```

| ฟิลด์ | ความหมาย | ความมั่นใจ |
|---|---|---|
| `frame` | เลข PNG ในโฟลเดอร์ (`000.png` …) | ✅ ยืนยันแล้ว |
| `x`, `y` | **จุดกึ่งกลางของรูป** เทียบกับจุดเท้าตัวละคร (origin) → มุมซ้ายบน = `(x - w//2, y - h//2)` | ✅ ยืนยันด้วยการประกอบ paperdoll |
| `layer` | ลำดับซ้อน (ดูตารางใน 4.2) — **อาจเปลี่ยนรายเฟรม** เช่น หมวก 10↔12, อาวุธเสริม -1↔14 (อาวุธอ้อมไปหลังตัวตอนฟัน) | ✅ |
| `delay` | เวลาค้างเฟรม หน่วย tick ของเอนจิน (ยืน 7, เดิน 5) | ⚠️ ไม่รู้ ms/tick — ต้องจูนด้วยตา |
| `sound` | รหัสเสียงที่เล่นตอนถึงเฟรม (เช่น 500, 3101) | ⚠️ เดา |
| `item_ids` | ไอเทมในเกมที่ใช้ชิ้นนี้ (1 ชิ้นอาจใช้กับหลาย ID) | ✅ |
| `raw` | ค่าดิบ 15 ช่องครบ (ช่อง 7–13 น่าจะเป็นจุดเอฟเฟกต์/อาวุธ ยังไม่รู้) | — |

**ชื่อท่าในเกมต้นฉบับ** (ตัวละคร/ชุด ใช้ชุดเดียวกัน 32 ท่า):
`STAND_1, WALK_1, RUN_1, LJUMP_1-2, HJUMP_1-4, ASTAND_1, AREADY_1, ATTACK_1-7, DEFENSE_1, DAMAGE_1-2, SPELL_1-3, DEAD_1, SCREAM_1, STRETCH_1, STICK_1-3, UPPER_1-2`

## 4. การนำไปใช้ในโปรเจกต์เรา

### 4.1 ส่วนที่ใช้ได้ทันที (ง่าย)

| ระบบในโปรเจกต์ | ใช้อะไรจาก Ghost Assets | วิธี |
|---|---|---|
| **มอนสเตอร์** `entities/monsters/<n>/frames.tres` | `OBJ/Monster/m0xxxxx/` | ทำ SpriteFrames จาก PNG + ท่าจาก `_motion.json` → ใส่ใน `frames.tres` ของมอนตัวใหม่ (inherited จาก `monster.tscn`) |
| **ไอคอนไอเทม** `EquipmentData.icon` | `OBJ/Item/DP_*`, `ring`, `necklace` ฯลฯ (ไม่มี motion — เป็นรูปนิ่ง) | ลาก PNG ใส่ช่อง `icon` ใน `.tres` ของไอเทม |
| **UI** (HUD, กระเป๋า, ช่องสกิล) `ui/` | `zThailand/ui/common` (ปุ่ม ตัวเลข slider), `image/ui` | ใช้เป็น `TextureButton` / `NinePatchRect` / theme |
| **ฉากหลัง** `levels/village.tscn` | `Back/*.png` | `Parallax2D` / `ParallaxBackground` หลายชั้น |
| **แผนที่** | `Tile/*.png` | ⚠️ tile ในเกมนี้เป็นชิ้น "แท่นหิน/พื้น" ขนาดไม่เท่ากัน ไม่ใช่ grid 16/32px → ใช้เป็น `Sprite2D` + `StaticBody2D` วางเอง ง่ายกว่าทำ TileSet |
| **เสียง** | `sound/*.wav`, `*.mp3` | `AudioStreamPlayer2D` ใน player/monster/skill |
| **เอฟเฟกต์สกิล** `skills/` | `OBJ/Effect/` | AnimatedSprite2D ชั่วคราว spawn ตอนใช้สกิล |

### 4.2 ตัวละคร paperdoll (ส่วนสำคัญ) — ตรงกับระบบที่เรามีอยู่แล้ว

ระบบเราตอนนี้ (`entities/player/player.tscn` + `player.gd`):
- `AnimatedSprite2D` (ตัว, `body_frames_m.tres` / `body_frames_f.tres`) + `FaceSprite` + `ArmorSprite` + `WeaponSprite`
- `_sync_layer()` บังคับทุกชั้นให้เล่น animation/frame เดียวกับตัว
- อุปกรณ์ให้ `SpriteFrames` ผ่าน `EquipmentData.get_frames(gender)` (`sprite_frames_male` / `sprite_frames_female`)

เกมต้นฉบับใช้หลักเดียวกันเป๊ะ → **ไม่ต้องเปลี่ยนสถาปัตยกรรม** แค่ต้องแปลงข้อมูล

**ปัญหาเดียว:** `SpriteFrames` ตั้ง offset รายเฟรมไม่ได้ แต่ Ghost ใช้ offset `x,y` ต่างกันทุกเฟรม
**ทางแก้ (แนะนำ):** ตอนแปลง ให้วางทุกเฟรมลงบน **canvas ขนาดคงที่** (เช่น 160×160) โดยจุดเท้าอยู่ตำแหน่งเดียวกันเสมอ → ทุกชั้นเรียงตรงกันเองโดยไม่ต้องแก้โค้ด (`centered = true`, ตั้ง `offset.y` ครั้งเดียวให้เท้าตรงพื้น)

แผนการแปลงชิ้นส่วน → Godot:

| ชั้นในโปรเจกต์ | แหล่งใน Ghost Assets | `layer` ที่พบ (→ `z_index`) |
|---|---|---|
| (ใหม่) `MantleSprite` | `Avatar/Avatar_mantle`, `mantle` | -4 (หลังตัว) |
| `AnimatedSprite2D` ตัว | `Avatar/avatar_skin/000_boy_blue`, `004_boy`, `005_girl` … (สีผิวต่างๆ ใช้ `boy.mot`/`girl.mot` ร่วมกัน) | 0 |
| `FaceSprite` | `Avatar/face`, `Avatar_face`, `avatar_face_2` | 4–5 |
| (ใหม่) `EyeSprite` | `Avatar/eye`, `Avatar_eye` | 10 |
| `ArmorSprite` | `Avatar/avatar_dress*`, `dress*` | 6 |
| (ใหม่) `HairSprite` | `Avatar/hair`, `Avatar_hair` | 10 |
| (ใหม่) `HatSprite` | `Avatar/hat`, `Avatar_hat` | 10–12 |
| `WeaponSprite` | `Avatar/weapon`, `Avatar_weapon` | 14 |
| (ใหม่) อาวุธเสริม | `Avatar/weaponacc`, `Avatar_weaponacc` | -1 / 14 |
| (ใหม่) เครื่องประดับผม | `Avatar/hairaccessory` | 15 |

`layer` เปลี่ยนได้รายเฟรม → ถ้าตั้ง `z_index` คงที่ต่อชั้นจะเพี้ยนบางท่า (เช่นอาวุธตอนฟันอ้อมหลังตัว) — ทางแก้: ตอน `_sync_layer` อ่าน layer ของเฟรมนั้นมาตั้ง `z_index` (เก็บไว้ใน metadata ของ SpriteFrames หรือ Resource แยก)

ชื่อชิ้นบอกเพศ: `_m_` = ชาย, `_w_` = หญิง, `_c_` = ใช้ร่วม (เช่น `d_m_m_001`, `h_w_t_000`, `w_c_m_001`)
→ map เข้า `sprite_frames_male` / `sprite_frames_female` ของ `EquipmentData`

**map ชื่อท่า Ghost → ชื่อท่าในโปรเจกต์** (ที่ `player.gd` เรียกอยู่):

| โปรเจกต์ | Ghost |
|---|---|
| `idle` | `STAND_1` |
| `walk` | `WALK_1` |
| `dash` | `RUN_1` |
| `jump` | `LJUMP_1` (หรือ `HJUMP_1-4` สำหรับกระโดดสูง) |
| `attack` | `ATTACK_1` (มี 1-7 ให้เลือกตามอาวุธ) |
| `shoot` | `ATTACK_x` ที่เป็นท่ายิง / `SPELL_1` |
| `die` | `DEAD_1` |
| (สกิล) `SkillData.animation` | `SPELL_1-3`, `ATTACK_4-7`, `UPPER_1-2` |
| (อนาคต) โดนตี | `DAMAGE_1-2` |

**จุดที่ต้องระวังตอนทำ:**
- สไปรต์ Ghost **หันซ้ายเป็นค่าเริ่มต้น** — โปรเจกต์เราตั้ง `flip_h = facing_direction < 0` (สมมติหันขวา) → ต้องกลับเป็น `facing_direction > 0` หรือ flip รูปตอนแปลง
- จำนวนเฟรมของแต่ละชั้นในท่าเดียวกันตรงกัน (ตัว 4 เฟรม ↔ ชุด 4 เฟรม) → `_sync_layer` ใช้ได้เลย
- `delay` → ตั้ง FPS ของแต่ละ animation หรือ duration รายเฟรมใน SpriteFrames (`add_frame(anim, tex, duration)`) แล้วจูนด้วยตา
- ชุดของ Ghost พอดีกับตัวของ Ghost เท่านั้น — ถ้าจะใช้ชุด Ghost ต้องใช้ตัว (`avatar_skin`) ของ Ghost ด้วย ห้ามผสมกับ `body_frames_m/f` เดิม

### 4.3 ขั้นต่อไป (ยังไม่ได้ทำ)

1. เขียนสคริปต์แปลง `ชิ้นส่วน + _motion.json` → PNG บน canvas คงที่ + `SpriteFrames .tres` (ชื่อท่าตาม 4.2) ลงใน `entities/player/sprites/` และ `items/`
2. เพิ่มชั้น `HairSprite`, `HatSprite`, `MantleSprite` ใน `player.tscn` + ใส่ใน `_sync_layers()` + slot ใหม่ใน `EquipmentData.slot` / `AppearanceData`
3. สร้าง `.tres` ไอเทมตัวอย่างจาก `item_ids`
4. ทำมอนสเตอร์ตัวใหม่จาก `OBJ/Monster/`

## 5. ฟอร์แมตไฟล์ที่แกะได้ (reverse-engineered)

ทุกไฟล์เป็น little-endian, ชื่อไฟล์/ข้อความเป็น **CP949 (EUC-KR)**

### `.spr` — สไปรต์ (หลายเฟรม)
```
0x000  name block 0x80 bytes (path ไฟล์ + ขยะ)
0x080  name block 0x80 bytes
0x100  u32 frame_count
ต่อเฟรม:
  u32 frame_id
  u32 n, n × 16B rect (x1,y1,x2,y2 i32)   ← hitbox ชุด 1
  u32 m, m × 16B rect                      ← hitbox ชุด 2
  16B block: 01 03|04 00 ... 00 ff 00 ff   ← byte[1]: 03 = ARGB1555, 04 = BGRA8888
  u16 w, 2B junk, u16 h, 2B junk, u32 pixel_count
  pixel_count × (2|4) bytes                ← ใช้แค่ w*h แรก (บางเฟรมเกินมา 2 px)
```
- ARGB1555: bit15 = ทึบ (0 = โปร่งใส), RGB 5-5-5
- บางไฟล์มี trailer ไม่เกิน 8 bytes ท้ายไฟล์

### `.mot` — ท่าทาง
```
0x000  name block 0x80 ×2
0x100  u32 motion_count
ต่อท่า: u32 0, char name[12], 4B junk, u32 (4), u32 frame_count,
        frame_count × 15 × i16   ← ดูความหมายในหัวข้อ 3
```

### `.csp` — รวมหลาย `.spr` (ชิ้นส่วน avatar / ไอคอน / เอฟเฟกต์)
```
u32 count, count × (u32 offset, u32 0)
ที่ offset: u32 0, u32 k, k × u32 item_id, แล้วตามด้วย .spr ปกติ
```
(ไฟล์เก่าบางไฟล์ไม่มี prefix — ตัวแปลงลองทั้งสองแบบแล้วเช็คว่าจบตรง offset ถัดไป)

### `.cmo` — รวมหลาย `.mot` (คู่กับ `.csp`)
```
u32 count, แล้วเรียงต่อกัน: u32 idx, u32 k, k × u32 item_id, .mot
```
- ไฟล์ใหม่ (`Avatar_mantle`, `Avatar_weapon`) มี trailer u32 แทรกระหว่าง/ท้ายรายการ
- ไฟล์เก่า (`soul.cmo`, `other.cmo`) ไม่มี prefix
- **จับคู่ csp↔cmo ด้วย item_id** (จำนวนรายการไม่เท่ากันเสมอ เช่น weapon 763 vs 762; `boy.mot` 1 รายการใช้กับผิว 9 สี) → fallback ชื่อไฟล์ → ลำดับ

### `.bg` — ภาพพื้นหลัง
```
byte0 = 3 (ARGB1555) | 4 (BGRA8888)
u16 w @0x0F, u16 h @0x11, u32 w*h @0x17, pixels @27
```

### `.til` — tileset
- แบบปกติ: block `0103` เดียว 1024×1024 เริ่มที่ byte 4
- แบบหลาย atlas (`_0.til`, `t14_*.til`): header `u32 n, 32, 32, 32, u32 m` + ข้อมูล grid + n × block 256×256 → ตัวแปลงสแกนหา block marker

### ยังไม่ได้แกะ (เป็นข้อมูล ไม่ใช่รูป)
| นามสกุล | น่าจะเป็น |
|---|---|
| `.map` (782) | เลย์เอาต์แผนที่ (วาง tile/วัตถุ) |
| `.prj` (1,305) | ข้อมูลฉาก/โปรเจกต์ของแต่ละแผนที่ |
| `.luc` / `.lua` (~935) | สคริปต์ Lua (compiled) — เควส/NPC |
| `.tbl`, `.etb`, `.att`, `.cob` | ตารางข้อมูล, attribute ของ tile (collision?) |

## 6. สิ่งที่แกะไม่ได้

| ไฟล์ | สาเหตุ |
|---|---|
| `data/OBJ/Monster/M000011.spr` (+ สำเนา `zThailand/table/m000011.spr`) | ถูกเข้ารหัส (entropy 8.0) ต้อง reverse `Game.exe` — ไม่มีไฟล์ไหนอ้างถึง |
| `data/OBJ/Monster/M000012.spr` (+ สำเนา) | ข้อมูลเสีย ไม่มี header — ไม่มีไฟล์ไหนอ้างถึง |

`.csp` ใน `OBJ/Item` (~14,780 ชิ้น เช่น `DP_*`) ไม่มี `.cmo` คู่ → ไม่มี `_motion.json` ซึ่งปกติ เพราะเป็นไอคอนนิ่ง

## 7. สคริปต์แปลง

อยู่ใน scratchpad ของ session (ชั่วคราว — **ถ้าจะใช้ซ้ำให้ย้ายมาเก็บใน `tools/ghost_extract/`**):
`C:\Users\fF\AppData\Local\Temp\claude\c--Users-fF-Desktop-game-rpg-2d\96bf33d1-796b-4da3-a131-dcb0bbc2a937\scratchpad\`

| สคริปต์ | หน้าที่ |
|---|---|
| `spr2png.py` | parser `.spr`/`.csp` + เขียน PNG (ไม่ใช้ Pillow) |
| `mot.py` | parser `.mot` + export `_motion.json` ทุกไฟล์ |
| `cmo.py` | parser `.cmo` |
| `avatar_export.py` | `.csp`+`.cmo` → PNG + `_motion.json` (`python avatar_export.py` = Avatar, `--non-avatar` = ที่เหลือ) |
| `bgtil.py` | `.bg`/`.til` → PNG |
| `rest.py` | UI นอก `data/`, bg/til, copy เสียง/bmp/avi |
| `compose.py`, `paperdoll.py` | ทดสอบประกอบ paperdoll (ต้องมี Pillow) → `paperdoll.png` |

ต้องใช้ Python 3.12 (มี Pillow 12 แล้วในเครื่อง)
