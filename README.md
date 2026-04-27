# Adventures of Bean: The Spire of Unending Ruin

A mobile roguelite built in Godot 4.6.2. Fight through three towers of 36 floors each, choosing from three characters, collecting weapons, and spending gold on upgrades between runs.

## Gameplay

- **3 playable characters** — Warrior, Healer, Wizard, each with unique stats and spells
- **3 towers** — Ashen Keep → Drowned Vaults → Brass Citadel, unlocked in sequence
- **36 floors per tower** — boss fight every 6th floor
- **6 weapons** — from Rusty Sword to Star Marrow Blade (common / rare / legendary)
- **5 enemy types** — Stone Shambler, Ash Wraith, Fungal Crawler, Brass Automaton, Drowned Soldier
- Touch controls — virtual joystick movement, tap to attack, double-tap to cast spells

## Tech

- **Engine:** Godot 4.6.2 — GL Compatibility renderer (mobile-safe)
- **Resolution:** 854×480 landscape
- **Language:** GDScript
- **Art:** Pixel art generated via PixelLab MCP

## Characters

| Character | Hearts | Spell |
|---|---|---|
| Warrior | 6 | Earthquake (AoE shockwave) |
| Healer | 5 | Tidal Surge (wave push) |
| Wizard | 4 | Meteor (targeted impact) |

## Towers

| Tower | Floors | Enemy Pool | Unlock |
|---|---|---|---|
| The Ashen Keep | 1–36 | Stone Shambler, Ash Wraith, Fungal Crawler | Default |
| The Drowned Vaults | 1–36 | Drowned Soldier, Fungal Crawler, Ash Wraith | Complete Ashen Keep |
| The Brass Citadel | 1–36 | Brass Automaton, Stone Shambler, Drowned Soldier | Complete Drowned Vaults |

## Running the Project

1. Download [Godot 4.6.2](https://godotengine.org/)
2. Clone this repo
3. Open `project.godot` in Godot
4. Hit Play
