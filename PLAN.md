# The Spire of Unending Ruin — Master Plan

Godot 4.6.2 · Landscape 854×480 · GL Compatibility · Mobile Roguelite

---

## PixelLab MCP — What It Does

PixelLab MCP is a Model Context Protocol server that generates pixel art assets from AI prompts directly inside a coding assistant. All generation jobs are **non-blocking** — they return a job ID immediately and finish in the background (typically 2–5 minutes). Multiple jobs can be queued at once without waiting.

### Tools Available

| Tool | What It Generates |
|---|---|
| `create_character` | Character sprite sheets with 4 or 8 directional views |
| `animate_character` | Animations for existing characters (walk, attack, death, idle, etc.) |
| `get_character` | Poll status, get image URLs, ZIP download link |
| `create_topdown_tileset` | 16-tile Wang tilesets for seamless top-down terrain |
| `get_topdown_tileset` | Poll tileset status |
| `create_sidescroller_tileset` | Platform tilesets with transparent backgrounds |
| `create_isometric_tile` | Individual 3D-perspective tiles (32px recommended) |
| `create_map_object` | Transparent-background props (chests, torches, doors, etc.) |
| `create_tiles_pro` | Advanced tiles with custom view angle, hex, octagon, isometric shapes |

### Key Parameters (Characters)
- `proportions`: `default`, `chibi`, `cartoon`, `stylized`, `realistic_male`, `realistic_female`, `heroic`
- `view`: `low top-down` (RPG), `high top-down` (RTS), `side`
- `ai_freedom`: creativity vs. prompt adherence (default 750)
- `outline`, `shading`, `detail`: visual style controls
- `directions`: 4 or 8 — generates N/S/E/W (+ diagonals)

### Key Parameters (Tilesets)
- `lower_description` / `upper_description`: terrain type text prompts
- `transition_size`: 0 (sharp edge), 0.25 (medium), 0.5 (wide blend)
- `tile_size`: 16×16 default, 32×32 for higher quality
- `lower_base_tile_id` / `upper_base_tile_id`: chain tilesets for seamless biome transitions
- `view`: `low top-down` (RPG dungeon floors)

### Tileset Chaining (Biome Transitions)
Submit job → get `base_tile_id` immediately → pass to next tileset as `lower_base_tile_id`. No waiting between submits. Enables chains like: `stone floor → cracked stone → bone floor → void`.

### Animation Templates Available
`breathing-idle`, `fight-stance-idle-8-frames`, `walk-cycle` (4 directions), `cross-punch`, `flying-kick`, `fireball`, `falling-back-death`, `crouching`, `crouched-walking`, `backflip`, `drinking`, and more.

### Job Polling Flow
1. Submit creation → receive `job_id` or `character_id` instantly
2. Queue all other jobs without waiting
3. Poll with `get_character` / `get_topdown_tileset` / etc.
4. Download when status = ✅ completed

---

## What We Have Done

### Phase 1 — Project Foundation ✅

**`project.godot`**
- Name: "The Spire of Unending Ruin"
- Resolution: 854×480, stretch mode `canvas_items`, orientation landscape
- Renderer: GL Compatibility (mobile-safe)
- Autoload: `GameState` → `res://scripts/autoloads/GameState.gd`
- Main scene: `res://scenes/ui/MainMenu.tscn`

**`scripts/autoloads/GameState.gd`** — Full singleton covering:
- 3 characters: Warrior (6 hearts), Healer (5 hearts), Wizard (4 hearts)
- 3 spells: Earthquake, Tidal Surge, Meteor — with energy cost, cooldown, radius/push
- 6 weapons: Rusty Sword → Star Marrow Blade (common / rare / legendary)
- Skill trees: 6 nodes per character with prerequisite chains and gold costs
- 5 enemy types with HP, damage, speed, color
- Floor difficulty scaling (+10% per floor), boss every 6th floor
- Run state (floor, hearts, energy, buffs) and permanent state (gold, unlocks)
- Save/load via `user://spire_save.json`

**`scenes/ui/MainMenu.tscn` + `scripts/ui/MainMenu.gd`**
- Title, subtitle, Start/Characters/Quit buttons
- Calls `GameState.load_save()` on ready

**`scenes/hub/HubScene.tscn` + `scripts/ui/HubScene.gd`**
- 854×1440 scrollable hub world
- Three interactable Area2D zones: Gate (→ Floor 01), Shrine (→ CharacterSelect), Merchant (→ ShopScreen)
- CharacterBody2D player with Camera2D (limits 0,0,854,1440, position smoothing)
- Virtual joystick (touch drag) for movement
- Proximity-based interact prompt via CanvasLayer label
- Fixed: `get_viewport().get_canvas_transform()` for world→screen conversion

**`scenes/ui/DeathScreen.tscn` + `scripts/ui/DeathScreen.gd`**
- Shows floor reached and gold collected
- Calls `GameState.die()` to reset run state
- Try Again → Hub, Main Menu → MainMenu

**`scenes/ui/CharacterSelect.tscn` + `scripts/ui/CharacterSelect.gd`**
- TopBar with Back button and title
- Three character buttons (160×200) built from `GameState.CHARACTERS`
- Shows name, heart count, lock/select state
- Disabled if character not unlocked

---

## What We Will Do

### Phase 2 — Floor System

**`scenes/floors/Floor01.tscn` … `Floor30.tscn`**
- Each floor is a self-contained room dungeon with random layout seeded by floor number
- Tileset: top-down Wang tiles (stone/dungeon theme), 16×16
- Spawns enemies scaled by `GameState.get_floor_difficulty()`
- Door/exit locked until all enemies cleared
- Every 6th floor = boss room (single large enemy, richer loot)
- Treasure room chance after each cleared floor

**Floor scene structure:**
```
FloorXX (Node2D)
├── TileMapLayer (floor tiles)
├── TileMapLayer (wall tiles)
├── EnemySpawner (spawns from pool based on floor range)
├── Player (instanced from scenes/entities/Player.tscn)
├── Exit (Area2D — locked until cleared)
├── UILayer (CanvasLayer)
│   ├── HeartBar
│   ├── EnergyBar
│   ├── WeaponLabel
│   └── PauseButton
└── Camera2D (follows player)
```

**PixelLab assets needed:**
- `create_topdown_tileset` — stone dungeon floor, `tile_size=16`, `view=low top-down`
- `create_topdown_tileset` — cracked stone floor (chains from stone via `lower_base_tile_id`)
- `create_topdown_tileset` — bone/void floor for floors 25–30
- `create_topdown_tileset` — boss room dark stone with glowing runes
- `create_map_object` — dungeon walls (top, side, corner variants), `view=low top-down`

---

### Phase 3 — Player Entity

**`scenes/entities/Player.tscn` + `scripts/player/Player.gd`**
- CharacterBody2D
- Reads stats from `GameState` (speed, hearts, attack damage/speed, weapon, spell)
- Virtual joystick input (same system as HubScene)
- Melee attack on tap near enemy; spell on double-tap or dedicated button
- Energy gain on kill; spell fires when `GameState.is_spell_ready()`
- Emits `died` signal → floor loads DeathScreen

**Attack system:**
- Melee: instantiates `Projectile.tscn` arc (or direct hitbox) based on weapon range
- Spell — Warrior: shockwave AoE circle; Healer: wave push; Wizard: targeted meteor

**PixelLab assets needed:**
- `create_character` × 3 — Warrior, Healer, Wizard; `proportions=stylized`, `view=low top-down`, 4 directions, `image_size=32`
- `animate_character` per character — `breathing-idle`, `walk-cycle`, `cross-punch` (melee), `fireball` / `flying-kick` / `crouching` (spells), `falling-back-death`
- `create_map_object` — spell FX: earthquake crack, tidal wave, meteor fireball

---

### Phase 4 — Enemy System

**`scenes/entities/Enemy.tscn` + `scripts/enemies/Enemy.gd`**
- CharacterBody2D
- Reads base stats from `GameState.get_scaled_enemy(enemy_id)`
- Simple state machine: Idle → Chase → Attack → Dead
- Chase range, attack range, knockback on hit
- Drops gold on death; energy added to player

**5 enemy types:**
| ID | Name | Behavior |
|---|---|---|
| `stone_shambler` | Stone Shambler | Slow, tanky melee charger |
| `ash_wraith` | Ash Wraith | Fast, fragile, erratic movement |
| `fungal_crawler` | Fungal Crawler | Slow, leaves damage trail |
| `brass_automaton` | Brass Automaton | Ranged projectile, high HP |
| `drowned_soldier` | Drowned Soldier | Medium stats, group spawner |

**PixelLab assets needed:**
- `create_character` × 5 — one per enemy type; `view=low top-down`, 4 directions, `image_size=24`
- `animate_character` per enemy — `breathing-idle`, `walk-cycle`, `cross-punch` (attack), `falling-back-death`

---

### Phase 5 — Loot & Chest System

**`scenes/entities/Chest.tscn`**
- Static map object, tap to open
- Spawns weapon or gold based on floor range and rarity weights
- `create_map_object` — closed chest, open chest, `view=low top-down`, `image_size=32`

**`scenes/ui/TreasureRoom.tscn`**
- Appears between floors (random chance, guaranteed every 5 floors)
- Shows 3 item cards: weapon upgrade or run buff
- Player picks one, rest discarded

**`scenes/ui/ShopScreen.tscn`**
- Merchant in hub sells: weapon unlocks, character unlocks, skill tree nodes
- Prices from `GameState.SKILL_TREES` cost fields and fixed weapon prices

---

### Phase 6 — UI Polish

**`scenes/ui/PauseMenu.tscn`**
- Resume / Restart Floor / Quit to Hub
- Shows current floor, hearts, gold, active buffs

**HeartBar / EnergyBar (in-floor HUD)**
- Heart sprites (full/half/empty) from `GameState.current_hearts`
- Energy fill bar tied to `GameState.energy / GameState.max_energy`

**PixelLab assets needed:**
- `create_map_object` — heart icon (full, half, empty), `image_size=16`
- `create_map_object` — energy orb / bar cap icons
- `create_map_object` — weapon icons for all 6 weapons, `image_size=16`
- `create_map_object` — gold coin, `image_size=16`

---

### Phase 7 — Hub World Art

**Hub world visual pass:**
- Background: dark stone citadel environment
- Gate: large glowing archway
- Shrine: glowing altar
- Merchant: hooded figure at stall

**PixelLab assets needed:**
- `create_topdown_tileset` — hub stone cobblestone floor, `tile_size=16`
- `create_map_object` — gate archway sprite, `view=low top-down`, `image_size=64`
- `create_map_object` — shrine altar, `image_size=48`
- `create_map_object` — merchant stall, `image_size=48`
- `create_map_object` — ambient props: torches, rubble, banners

---

### Phase 8 — Audio & Juice

- Hit sound, spell sounds, footstep, chest open, death sting, floor clear fanfare
- Camera shake on hit received (Godot `Tween` offset)
- Screen flash on damage
- Particle burst on enemy death (CPUParticles2D)
- Screenshake + color flash on spell cast

---

## Asset Delivery Path

All PixelLab-generated assets land in:

```
res://art/
├── characters/   warrior/, healer/, wizard/   (spritesheet PNGs per direction)
├── enemies/      stone_shambler/, ash_wraith/, etc.
├── weapons/      icons (16×16 PNGs)
├── ui/           hearts, energy, gold coin, buttons
├── tiles/        floor_stone.png, floor_cracked.png, floor_bone.png, hub_cobble.png
└── backgrounds/  hub_bg.png, boss_bg.png
```

Godot import: save base64 PNG from PixelLab → `Image.load_png_from_buffer()` or drop into `res://art/` and import as `2D Pixel` texture (filter off, no mipmaps).

---

## Floor Progression Reference

| Floor Range | Theme | Enemy Pool | Tileset |
|---|---|---|---|
| 1–6 | Entrance Ruins | stone_shambler, ash_wraith | stone floor |
| 7–12 | Fungal Depths | fungal_crawler, ash_wraith | cracked stone |
| 13–18 | Brass Warrens | brass_automaton, stone_shambler | dark stone |
| 19–24 | Drowned Halls | drowned_soldier, fungal_crawler | cracked + bone |
| 25–30 | The Spire Core | all types | bone / void |
| 6, 12, 18, 24, 30 | Boss Floors | single elite enemy | boss room |

---

## Tower Structure

3 towers × 36 floors each. Boss every 6th floor (6, 12, 18, 24, 30, 36).

| Tower | ID | Enemy Pool | Unlock Condition |
|---|---|---|---|
| The Ashen Keep | `ashen_keep` | stone_shambler, ash_wraith, fungal_crawler | Default (always available) |
| The Drowned Vaults | `drowned_vaults` | drowned_soldier, fungal_crawler, ash_wraith | Complete Ashen Keep (36 floors) |
| The Brass Citadel | `brass_citadel` | brass_automaton, stone_shambler, drowned_soldier | Complete Drowned Vaults (36 floors) |

Tower progress is tracked per-tower in `GameState.tower_floors_completed`. Completing a tower unlocks the next via `_check_tower_unlocks()`.

## Scene Navigation Map

```
MainMenu
├── → HubScene (Start Game / back from CharacterSelect)
│   ├── Gate → TowerSelect
│   │   ├── Ashen Keep (unlocked) → Floor01 … Floor36
│   │   ├── Drowned Vaults (locked until Ashen complete) → Floor01 … Floor36
│   │   └── Brass Citadel (locked until Drowned complete) → Floor01 … Floor36
│   ├── Shrine → CharacterSelect → HubScene
│   └── Merchant → ShopScreen → HubScene
├── → CharacterSelect → MainMenu
Floor (death) → DeathScreen → HubScene / MainMenu
Floor (cleared, not last) → TreasureRoom → next Floor
Floor 36 cleared → tower conquered, back to HubScene
```
