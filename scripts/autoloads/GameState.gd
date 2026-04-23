extends Node
# =============================================================================
# GameState.gd
# res://scripts/autoloads/GameState.gd
# =============================================================================

const CHARACTERS : Dictionary = {
	"warrior": {
		"name"       : "Warrior",
		"max_hearts" : 6,
		"speed"      : 200.0,
		"attack_dmg" : 2,
		"attack_spd" : 1.0,
		"spell"      : "earthquake",
		"ultimate"   : "warcry",
		"color"      : Color("#1a2a0a"),
	},
	"healer": {
		"name"       : "Healer",
		"max_hearts" : 5,
		"speed"      : 210.0,
		"attack_dmg" : 1,
		"attack_spd" : 1.0,
		"spell"      : "tidal_surge",
		"ultimate"   : "healing_nova",
		"color"      : Color("#0a1a3a"),
	},
	"wizard": {
		"name"       : "Wizard",
		"max_hearts" : 4,
		"speed"      : 195.0,
		"attack_dmg" : 1,
		"attack_spd" : 1.0,
		"spell"      : "fireball",
		"ultimate"   : "kamehameha",
		"color"      : Color("#3a0a0a"),
	},
}

const SPELLS : Dictionary = {
	"earthquake": {
		"name"       : "Earthquake",
		"description": "Stomps the ground, damaging all nearby enemies.",
		"base_damage": 3,
		"radius"     : 120.0,
		"cooldown"   : 8.0,
		"energy_cost": 30.0,
	},
	"tidal_surge": {
		"name"       : "Tidal Surge",
		"description": "Sends a wave pushing and damaging all enemies.",
		"base_damage": 2,
		"push_force" : 300.0,
		"cooldown"   : 6.0,
		"energy_cost": 25.0,
	},
	"meteor": {
		"name"       : "Meteor",
		"description": "Calls a fire meteor on a targeted area.",
		"base_damage": 5,
		"radius"     : 80.0,
		"cooldown"   : 10.0,
		"energy_cost": 40.0,
	},
	"fireball": {
		"name"            : "Fireball",
		"description"     : "Launches a fireball that travels and explodes on impact.",
		"base_damage"     : 3,
		"projectile_speed": 270.0,
		"range"           : 400.0,
		"cooldown"        : 3.0,
		"energy_cost"     : 20.0,
	},
	"kamehameha": {
		"name"       : "Kamehameha",
		"description": "A devastating fire beam. Hold to aim, release to fire.",
		"base_damage": 10,
		"beam_width" : 34.0,
		"range"      : 720.0,
		"cooldown"   : 12.0,
		"energy_cost": 60.0,
	},
	"warcry": {
		"name"       : "Warcry",
		"description": "A devastating strike that damages all nearby enemies.",
		"base_damage": 6,
		"radius"     : 160.0,
		"cooldown"   : 10.0,
		"energy_cost": 50.0,
	},
	"healing_nova": {
		"name"       : "Healing Nova",
		"description": "Releases a healing burst, restoring HP and damaging enemies.",
		"base_damage": 3,
		"heal"       : 2,
		"radius"     : 140.0,
		"cooldown"   : 10.0,
		"energy_cost": 50.0,
	},
}

const WEAPONS : Dictionary = {
	"rusty_sword": {
		"name": "Rusty Sword",        "tier": "common",
		"damage": 1,  "speed": 1.00, "range": 50.0,  "slash_arc": 60.0,
		"cost": 0,    "desc": "A worn blade. Better than nothing.",
	},
	"cracked_shortsword": {
		"name": "Cracked Shortsword", "tier": "common",
		"damage": 2,  "speed": 1.00, "range": 55.0,  "slash_arc": 70.0,
		"cost": 50,   "desc": "Chipped but still cuts.",
	},
	"copper_blade": {
		"name": "Copper Blade",       "tier": "common",
		"damage": 3,  "speed": 0.95, "range": 60.0,  "slash_arc": 80.0,
		"cost": 100,  "desc": "Soft metal, wide swings.",
	},
	"iron_sword": {
		"name": "Iron Sword",         "tier": "common",
		"damage": 4,  "speed": 0.90, "range": 65.0,  "slash_arc": 90.0,
		"cost": 180,  "desc": "Reliable iron, quarter-circle arc.",
	},
	"steel_longsword": {
		"name": "Steel Longsword",    "tier": "uncommon",
		"damage": 6,  "speed": 0.85, "range": 75.0,  "slash_arc": 110.0,
		"cost": 300,  "desc": "Reach and steel. A soldier's tool.",
	},
	"knights_blade": {
		"name": "Knight's Blade",     "tier": "uncommon",
		"damage": 8,  "speed": 0.82, "range": 80.0,  "slash_arc": 130.0,
		"cost": 480,  "desc": "Blessed by the Order of Stone.",
	},
	"silver_edge": {
		"name": "Silver Edge",        "tier": "uncommon",
		"damage": 10, "speed": 0.88, "range": 80.0,  "slash_arc": 150.0,
		"cost": 700,  "desc": "Burns with cold silver light.",
	},
	"enchanted_sword": {
		"name": "Enchanted Sword",    "tier": "rare",
		"damage": 13, "speed": 0.92, "range": 85.0,  "slash_arc": 160.0,
		"cost": 1000, "desc": "Hums with arcane energy.",
	},
	"venom_fang": {
		"name": "Venom Fang",         "tier": "rare",
		"damage": 15, "speed": 1.05, "range": 80.0,  "slash_arc": 140.0,
		"cost": 1350, "desc": "Fast strikes laced with toxin.",
	},
	"shadowblade": {
		"name": "Shadowblade",        "tier": "rare",
		"damage": 18, "speed": 0.95, "range": 90.0,  "slash_arc": 170.0,
		"cost": 1800, "desc": "Cuts through shadow itself.",
	},
	"moonreaver": {
		"name": "Moonreaver",         "tier": "epic",
		"damage": 22, "speed": 0.88, "range": 95.0,  "slash_arc": 185.0,
		"cost": 2400, "desc": "A half-circle of pale destruction.",
	},
	"void_edge": {
		"name": "Void Edge",          "tier": "epic",
		"damage": 26, "speed": 0.85, "range": 100.0, "slash_arc": 220.0,
		"cost": 3200, "desc": "Tears space as it swings.",
	},
	"doomcleaver": {
		"name": "Doomcleaver",        "tier": "epic",
		"damage": 31, "speed": 0.80, "range": 110.0, "slash_arc": 260.0,
		"cost": 4200, "desc": "Doom comes to all in its path.",
	},
	"celestial_blade": {
		"name": "Celestial Blade",    "tier": "legendary",
		"damage": 37, "speed": 0.82, "range": 120.0, "slash_arc": 310.0,
		"cost": 5500, "desc": "Forged in a dying star.",
	},
	"star_marrow_blade": {
		"name": "Star Marrow Blade",  "tier": "legendary",
		"damage": 44, "speed": 0.85, "range": 130.0, "slash_arc": 360.0,
		"cost": 7200, "desc": "Strikes every enemy around you.",
	},
	# ── Custom weapons ────────────────────────────────────────────────────────
	"sage_wand": {
		"name": "Sage Wand",          "tier": "common",
		"damage": 2,  "speed": 1.10, "range": 55.0,  "slash_arc": 65.0,
		"cost": 80,   "desc": "A plain wand. Quick to cast.",
		"sprite": "res://art/weapons/weapon_13.png",
	},
	"silver_sword": {
		"name": "Silver Sword",       "tier": "common",
		"damage": 3,  "speed": 1.00, "range": 65.0,  "slash_arc": 75.0,
		"cost": 120,  "desc": "Clean silver steel, reliably sharp.",
		"sprite": "res://art/weapons/weapon_02.png",
	},
	"oaken_maul": {
		"name": "Oaken Maul",         "tier": "common",
		"damage": 4,  "speed": 0.85, "range": 60.0,  "slash_arc": 100.0,
		"cost": 160,  "desc": "Slow but each swing bruises deeply.",
		"sprite": "res://art/weapons/weapon_10.png",
	},
	"knights_sword": {
		"name": "Knight's Sword",     "tier": "common",
		"damage": 5,  "speed": 0.95, "range": 70.0,  "slash_arc": 80.0,
		"cost": 200,  "desc": "Standard issue for the city guard.",
		"sprite": "res://art/weapons/weapon_23.png",
	},
	"vine_bow": {
		"name": "Vine Bow",           "tier": "uncommon",
		"damage": 6,  "speed": 1.05, "range": 85.0,  "slash_arc": 90.0,
		"cost": 320,  "desc": "Grown from living vines. Whisper-quiet.",
		"sprite": "res://art/weapons/weapon_19.png",
	},
	"spark_fork": {
		"name": "Spark Fork",         "tier": "uncommon",
		"damage": 7,  "speed": 1.00, "range": 75.0,  "slash_arc": 105.0,
		"cost": 350,  "desc": "Two prongs channel crackling lightning.",
		"sprite": "res://art/weapons/weapon_01.png",
	},
	"crystal_staff": {
		"name": "Crystal Staff",      "tier": "uncommon",
		"damage": 7,  "speed": 1.00, "range": 80.0,  "slash_arc": 100.0,
		"cost": 380,  "desc": "A green crystal amplifies spell force.",
		"sprite": "res://art/weapons/weapon_12.png",
	},
	"runic_hatchet": {
		"name": "Runic Hatchet",      "tier": "uncommon",
		"damage": 8,  "speed": 0.90, "range": 72.0,  "slash_arc": 115.0,
		"cost": 450,  "desc": "Blue runes carved into ancient iron.",
		"sprite": "res://art/weapons/weapon_11.png",
	},
	"war_axe": {
		"name": "War Axe",            "tier": "uncommon",
		"damage": 9,  "speed": 0.85, "range": 70.0,  "slash_arc": 120.0,
		"cost": 550,  "desc": "Forged gold-plated for a warlord.",
		"sprite": "res://art/weapons/weapon_04.png",
	},
	"druids_staff": {
		"name": "Druid's Staff",      "tier": "rare",
		"damage": 13, "speed": 0.92, "range": 90.0,  "slash_arc": 130.0,
		"cost": 1000, "desc": "Bound with living leaves and nature magic.",
		"sprite": "res://art/weapons/weapon_17.png",
	},
	"grimoire_mace": {
		"name": "Grimoire Mace",      "tier": "rare",
		"damage": 13, "speed": 0.88, "range": 80.0,  "slash_arc": 135.0,
		"cost": 1050, "desc": "A dark tome fused to a crushing head.",
		"sprite": "res://art/weapons/weapon_16.png",
	},
	"verdant_staff": {
		"name": "Verdant Staff",      "tier": "rare",
		"damage": 14, "speed": 0.95, "range": 90.0,  "slash_arc": 150.0,
		"cost": 1100, "desc": "A gem of living forest breathes within.",
		"sprite": "res://art/weapons/weapon_00.png",
	},
	"serpent_staff": {
		"name": "Serpent Staff",      "tier": "rare",
		"damage": 14, "speed": 0.90, "range": 95.0,  "slash_arc": 140.0,
		"cost": 1150, "desc": "Twisted gold coils like a striking snake.",
		"sprite": "res://art/weapons/weapon_09.png",
	},
	"crimson_fang": {
		"name": "Crimson Fang",       "tier": "rare",
		"damage": 15, "speed": 1.10, "range": 82.0,  "slash_arc": 145.0,
		"cost": 1200, "desc": "A curved spike that tears and bleeds.",
		"sprite": "res://art/weapons/weapon_05.png",
	},
	"azure_bow": {
		"name": "Azure Bow",          "tier": "rare",
		"damage": 15, "speed": 1.00, "range": 100.0, "slash_arc": 145.0,
		"cost": 1300, "desc": "Drawn from deep ocean glass.",
		"sprite": "res://art/weapons/weapon_18.png",
	},
	"frostfang_hook": {
		"name": "Frostfang Hook",     "tier": "rare",
		"damage": 16, "speed": 1.00, "range": 85.0,  "slash_arc": 155.0,
		"cost": 1400, "desc": "A blue-flamed hook that bites with cold.",
		"sprite": "res://art/weapons/weapon_08.png",
	},
	"rose_saber": {
		"name": "Rose Saber",         "tier": "rare",
		"damage": 17, "speed": 1.05, "range": 88.0,  "slash_arc": 160.0,
		"cost": 1600, "desc": "Beauty and bloodshed in one curved edge.",
		"sprite": "res://art/weapons/weapon_14.png",
	},
	"regal_scepter": {
		"name": "Regal Scepter",      "tier": "epic",
		"damage": 24, "speed": 0.90, "range": 95.0,  "slash_arc": 195.0,
		"cost": 2500, "desc": "Gold and gemstone housing immense power.",
		"sprite": "res://art/weapons/weapon_07.png",
	},
	"razorclaw": {
		"name": "Razorclaw",          "tier": "epic",
		"damage": 25, "speed": 1.05, "range": 92.0,  "slash_arc": 200.0,
		"cost": 2600, "desc": "Crimson talons that rend through armor.",
		"sprite": "res://art/weapons/weapon_06.png",
	},
	"frost_edge": {
		"name": "Frost Edge",         "tier": "epic",
		"damage": 25, "speed": 0.92, "range": 100.0, "slash_arc": 205.0,
		"cost": 2800, "desc": "A glacial blade that freezes on impact.",
		"sprite": "res://art/weapons/weapon_24.png",
	},
	"soul_reaver": {
		"name": "Soul Reaver",        "tier": "epic",
		"damage": 26, "speed": 0.88, "range": 100.0, "slash_arc": 210.0,
		"cost": 3000, "desc": "Its dark core absorbs the light of the slain.",
		"sprite": "res://art/weapons/weapon_03.png",
	},
	"phantom_saber": {
		"name": "Phantom Saber",      "tier": "epic",
		"damage": 27, "speed": 0.95, "range": 98.0,  "slash_arc": 215.0,
		"cost": 3200, "desc": "Strikes from between dimensions.",
		"sprite": "res://art/weapons/weapon_20.png",
	},
	"emberblade": {
		"name": "Emberblade",         "tier": "epic",
		"damage": 28, "speed": 0.85, "range": 105.0, "slash_arc": 225.0,
		"cost": 3500, "desc": "Burns with an undying inner fire.",
		"sprite": "res://art/weapons/weapon_15.png",
	},
	"venom_serpent": {
		"name": "Venom Serpent",      "tier": "legendary",
		"damage": 38, "speed": 0.88, "range": 125.0, "slash_arc": 320.0,
		"cost": 5800, "desc": "A serpentine blade dripping with venom.",
		"sprite": "res://art/weapons/weapon_21.png",
	},
	"tri_blade": {
		"name": "Tri-Blade",          "tier": "legendary",
		"damage": 45, "speed": 0.80, "range": 135.0, "slash_arc": 360.0,
		"cost": 7500, "desc": "Three blades fused. Nothing survives the arc.",
		"sprite": "res://art/weapons/weapon_22.png",
	},
}

const SKILL_TREES : Dictionary = {
	"warrior": {
		"eq_dmg_1"    : {"name": "Tremor I",      "desc": "Earthquake damage +2",        "cost": 50,  "requires": [],                      "effect": {"base_damage": 2}},
		"eq_dmg_2"    : {"name": "Tremor II",     "desc": "Earthquake damage +3",        "cost": 100, "requires": ["eq_dmg_1"],             "effect": {"base_damage": 3}},
		"eq_radius_1" : {"name": "Wide Crack",    "desc": "Earthquake radius +40",       "cost": 75,  "requires": ["eq_dmg_1"],             "effect": {"radius": 40.0}},
		"eq_radius_2" : {"name": "Fault Line",    "desc": "Earthquake radius +60",       "cost": 150, "requires": ["eq_radius_1"],          "effect": {"radius": 60.0}},
		"eq_stun"     : {"name": "Aftershock",    "desc": "Earthquake stuns enemies 1s", "cost": 200, "requires": ["eq_dmg_2","eq_radius_2"],"effect": {"stun": 1.0}},
		"eq_cooldown" : {"name": "Quick Tremor",  "desc": "Earthquake cooldown -2s",     "cost": 125, "requires": ["eq_dmg_1"],             "effect": {"cooldown": -2.0}},
	},
	"healer": {
		"ts_dmg_1"    : {"name": "Surge I",        "desc": "Tidal Surge damage +1",      "cost": 50,  "requires": [],           "effect": {"base_damage": 1}},
		"ts_dmg_2"    : {"name": "Surge II",       "desc": "Tidal Surge damage +2",      "cost": 100, "requires": ["ts_dmg_1"], "effect": {"base_damage": 2}},
		"ts_push_1"   : {"name": "Strong Current", "desc": "Push force +150",            "cost": 75,  "requires": ["ts_dmg_1"], "effect": {"push_force": 150.0}},
		"ts_heal_1"   : {"name": "Healing Waters", "desc": "Tidal Surge heals 1 heart",  "cost": 150, "requires": ["ts_dmg_1"], "effect": {"heal": 1}},
		"ts_heal_2"   : {"name": "Deep Mending",   "desc": "Tidal Surge heals 2 hearts", "cost": 250, "requires": ["ts_heal_1"],"effect": {"heal": 2}},
		"ts_cooldown" : {"name": "Quick Tide",     "desc": "Tidal Surge cooldown -2s",   "cost": 125, "requires": ["ts_dmg_1"], "effect": {"cooldown": -2.0}},
	},
	"wizard": {
		"mt_dmg_1"    : {"name": "Hotter Flame",   "desc": "Fireball damage +3",         "cost": 50,  "requires": [],                       "effect": {"base_damage": 3}},
		"mt_dmg_2"    : {"name": "Inferno",        "desc": "Fireball damage +5",         "cost": 100, "requires": ["mt_dmg_1"],             "effect": {"base_damage": 5}},
		"mt_radius_1" : {"name": "Wide Burst",     "desc": "Fireball blast radius +30",  "cost": 75,  "requires": ["mt_dmg_1"],             "effect": {"radius": 30.0}},
		"mt_radius_2" : {"name": "Crater",         "desc": "Fireball blast radius +50",  "cost": 150, "requires": ["mt_radius_1"],          "effect": {"radius": 50.0}},
		"mt_multi"    : {"name": "Firestorm",      "desc": "Fires 3 fireballs at once",  "cost": 300, "requires": ["mt_dmg_2","mt_radius_2"],"effect": {"multi": 3}},
		"mt_cooldown" : {"name": "Quick Cast",     "desc": "Fireball cooldown -3s",      "cost": 125, "requires": ["mt_dmg_1"],             "effect": {"cooldown": -3.0}},
	},
}

const ENEMIES : Dictionary = {
	"stone_shambler"  : {"name": "Stone Shambler",   "hp": 3, "damage": 1, "speed": 38.0,  "color": Color("#4a3a2a")},
	"ash_wraith"      : {"name": "Ash Wraith",       "hp": 2, "damage": 1, "speed": 58.0,  "color": Color("#6a6a6a")},
	"fungal_crawler"  : {"name": "Fungal Crawler",   "hp": 4, "damage": 1, "speed": 32.0,  "color": Color("#2a5a2a")},
	"brass_automaton" : {"name": "Brass Automaton",  "hp": 6, "damage": 2, "speed": 28.0,  "color": Color("#8a6a2a")},
	"drowned_soldier" : {"name": "Drowned Soldier",  "hp": 5, "damage": 1, "speed": 42.0,  "color": Color("#2a4a6a")},
}

const TOWERS : Dictionary = {
	"ashen_keep": {
		"name"        : "The Ashen Keep",
		"description" : "Ancient ruins haunted by ash and stone.",
		"floors"      : 10,
		"enemy_pool"  : ["stone_shambler", "ash_wraith", "fungal_crawler"],
		"color"       : Color("#4a3a2a"),
		"unlock_req"  : "",
	},
	"drowned_vaults": {
		"name"        : "The Drowned Vaults",
		"description" : "Flooded vaults cursed by the deep.",
		"floors"      : 36,
		"enemy_pool"  : ["drowned_soldier", "fungal_crawler", "ash_wraith"],
		"color"       : Color("#2a4a6a"),
		"unlock_req"  : "ashen_keep",
	},
	"brass_citadel": {
		"name"        : "The Brass Citadel",
		"description" : "A mechanical fortress of brass and gears.",
		"floors"      : 36,
		"enemy_pool"  : ["brass_automaton", "stone_shambler", "drowned_soldier"],
		"color"       : Color("#8a6a2a"),
		"unlock_req"  : "drowned_vaults",
	},
}

# ── Zone 1 floor definitions ──────────────────────────────────────────────────
const ZONE_1_FLOORS : Array = [
	{"name": "The Gatehouse",         "rooms": 5, "theme": "floor_01"},
	{"name": "The Sunken Parish",     "rooms": 6, "theme": "floor_02"},
	{"name": "The Ossified Market",   "rooms": 6, "theme": "floor_03"},
	{"name": "The Petrified Library", "rooms": 6, "theme": "floor_04"},
	{"name": "The Hollow Barracks",   "rooms": 7, "theme": "floor_05"},
	{"name": "The Calcified Sewers",  "rooms": 7, "theme": "floor_06"},
	{"name": "The Bridal Hall",       "rooms": 7, "theme": "floor_07"},
	{"name": "The Mayor's Mausoleum", "rooms": 7, "theme": "floor_08"},
	{"name": "The Bell Tower",        "rooms": 8, "theme": "floor_09"},
	{"name": "The Stone Archive",     "rooms": 8, "theme": "floor_10"},
]

# ── Run state — resets on death ───────────────────────────────────────────────
var current_floor      : int   = 1
var current_room       : int   = 1
var current_hearts     : int   = 5
var energy             : float = 0.0
var max_energy         : float = 100.0
var run_buffs          : Array = []
var visited_rooms      : Array = [1]   # session-only, not saved
var bonus_max_hearts   : int   = 0
var defense            : int   = 0
var attack_speed_bonus : float = 0.0

# ── Permanent state — never resets ────────────────────────────────────────────
var gold                : int        = 0
var selected_character  : String     = "wizard"
var unlocked_characters : Array      = ["warrior", "wizard", "healer"]
var unlocked_weapons    : Array      = ["rusty_sword"]
var current_weapon      : Dictionary = {}
var skill_tree_nodes    : Dictionary = {}

# ── Tower state ───────────────────────────────────────────────────────────────
var selected_tower         : String     = "ashen_keep"
var unlocked_towers        : Array      = ["ashen_keep"]
var tower_floors_completed : Dictionary = {}


func _ready() -> void:
	_init_skill_tree()
	_init_weapon()
	_init_hearts()


func _init_skill_tree() -> void:
	for char_id in CHARACTERS:
		if not skill_tree_nodes.has(char_id):
			skill_tree_nodes[char_id] = []


func _init_weapon() -> void:
	if current_weapon.is_empty():
		current_weapon = WEAPONS.get("rusty_sword", {}).duplicate()
		current_weapon["id"] = "rusty_sword"


func _init_hearts() -> void:
	current_hearts = get_max_hearts()


# ── Run management ────────────────────────────────────────────────────────────
func start_run() -> void:
	current_floor      = 1
	current_room       = 1
	visited_rooms      = [1]
	energy             = 0.0
	bonus_max_hearts   = 0
	defense            = 0
	attack_speed_bonus = 0.0
	run_buffs.clear()
	_init_hearts()
	save()


func die() -> void:
	current_floor      = 1
	current_room       = 1
	visited_rooms      = [1]
	energy             = 0.0
	bonus_max_hearts   = 0
	defense            = 0
	attack_speed_bonus = 0.0
	run_buffs.clear()
	_init_hearts()
	save()


func complete_tower_run() -> void:
	_record_tower_progress(current_floor)
	current_floor = 1
	current_room  = 1
	visited_rooms = [1]
	energy        = 0.0
	run_buffs.clear()
	save()


func advance_floor() -> void:
	_record_tower_progress(current_floor)
	current_floor += 1
	current_room   = 1
	visited_rooms  = [1]
	save()


func advance_room() -> void:
	current_room += 1
	if not current_room in visited_rooms:
		visited_rooms.append(current_room)
	save()


func go_to_room(room_id : int) -> void:
	current_room = room_id
	if not room_id in visited_rooms:
		visited_rooms.append(room_id)
	save()


func get_floor_graph() -> Dictionary:
	var count : int = get_floor_room_count()
	match count:
		5: return {1:[2], 2:[3,4], 3:[5], 4:[5], 5:[]}
		6: return {1:[2], 2:[3,4], 3:[6], 4:[5], 5:[], 6:[]}
		7: return {1:[2], 2:[3,4], 3:[5], 4:[6], 5:[7], 6:[], 7:[]}
		8: return {1:[2], 2:[3,4], 3:[5], 4:[6], 5:[7], 6:[8], 7:[], 8:[]}
		_:
			var g : Dictionary = {}
			for i in range(1, count + 1):
				g[i] = [i + 1] if i < count else []
			return g


func get_room_exits(room_id : int) -> Array:
	return get_floor_graph().get(room_id, [])


func get_floor_map_layout() -> Dictionary:
	## Returns {room_id: Vector2i(col, row)} for minimap drawing.
	var count : int = get_floor_room_count()
	match count:
		5: return {1:Vector2i(0,0), 2:Vector2i(1,0), 3:Vector2i(2,0),
				   4:Vector2i(2,1), 5:Vector2i(3,0)}
		6: return {1:Vector2i(0,0), 2:Vector2i(1,0), 3:Vector2i(2,0),
				   4:Vector2i(2,1), 5:Vector2i(3,1), 6:Vector2i(3,0)}
		7: return {1:Vector2i(0,0), 2:Vector2i(1,0), 3:Vector2i(2,0),
				   4:Vector2i(2,1), 5:Vector2i(3,0), 6:Vector2i(3,1), 7:Vector2i(4,0)}
		8: return {1:Vector2i(0,0), 2:Vector2i(1,0), 3:Vector2i(2,0),
				   4:Vector2i(2,1), 5:Vector2i(3,0), 6:Vector2i(3,1),
				   7:Vector2i(4,0), 8:Vector2i(4,1)}
		_:
			var layout : Dictionary = {}
			for i in range(1, count + 1):
				layout[i] = Vector2i(i - 1, 0)
			return layout


func get_floor_room_count() -> int:
	if selected_tower == "ashen_keep":
		var idx : int = current_floor - 1
		if idx >= 0 and idx < ZONE_1_FLOORS.size():
			return ZONE_1_FLOORS[idx].get("rooms", 6)
	return 6


func get_floor_theme() -> String:
	if selected_tower == "ashen_keep":
		var idx : int = current_floor - 1
		if idx >= 0 and idx < ZONE_1_FLOORS.size():
			return ZONE_1_FLOORS[idx].get("theme", "floor_01")
	return "floor_01"


func get_floor_display_name() -> String:
	if selected_tower == "ashen_keep":
		var idx : int = current_floor - 1
		if idx >= 0 and idx < ZONE_1_FLOORS.size():
			return ZONE_1_FLOORS[idx].get("name", "Unknown")
	return get_tower_name() + " — Floor " + str(current_floor)


func is_last_room() -> bool:
	return get_room_exits(current_room).is_empty()


func _record_tower_progress(floor_num : int) -> void:
	var best : int = tower_floors_completed.get(selected_tower, 0)
	if floor_num > best:
		tower_floors_completed[selected_tower] = floor_num
	_check_tower_unlocks()


func _check_tower_unlocks() -> void:
	for tower_id in TOWERS:
		if tower_id in unlocked_towers:
			continue
		var req : String = TOWERS[tower_id].get("unlock_req", "")
		if req.is_empty():
			continue
		var completed : int = tower_floors_completed.get(req, 0)
		var req_total : int = TOWERS.get(req, {}).get("floors", 36)
		if completed >= req_total:
			unlocked_towers.append(tower_id)


func is_boss_floor() -> bool:
	return current_floor == get_tower_floor_count()


func get_floor_difficulty() -> float:
	return 1.0 + (current_floor - 1) * 0.10


# ── Hearts ────────────────────────────────────────────────────────────────────
func get_max_hearts() -> int:
	return CHARACTERS.get(selected_character, {}).get("max_hearts", 5) + bonus_max_hearts


func take_damage(amount : int) -> void:
	var mitigated : int = max(amount - defense, 1)
	current_hearts = max(current_hearts - mitigated, 0)


func heal(amount : int) -> void:
	current_hearts = min(current_hearts + amount, get_max_hearts())


func heal_full() -> void:
	current_hearts = get_max_hearts()


func is_dead() -> bool:
	return current_hearts <= 0


# ── Energy ────────────────────────────────────────────────────────────────────
func add_energy(amount : float) -> void:
	energy = min(energy + amount, max_energy)


func spend_energy(amount : float) -> bool:
	if energy >= amount:
		energy -= amount
		return true
	return false


func is_spell_ready() -> bool:
	var spell : Dictionary = get_spell_stats()
	return energy >= spell.get("energy_cost", 999.0)


# ── Gold ──────────────────────────────────────────────────────────────────────
func add_gold(amount : int) -> void:
	gold += amount
	save()


func spend_gold(amount : int) -> bool:
	if gold >= amount:
		gold -= amount
		save()
		return true
	return false


# ── Weapons ───────────────────────────────────────────────────────────────────
func equip_weapon(weapon_id : String) -> void:
	if not weapon_id in unlocked_weapons:
		unlocked_weapons.append(weapon_id)
	current_weapon = WEAPONS.get(weapon_id, {}).duplicate()
	current_weapon["id"] = weapon_id
	save()


func get_weapon_damage() -> int:
	return current_weapon.get("damage", 1)


func get_weapon_speed() -> float:
	return current_weapon.get("speed", 1.0)


func get_weapon_range() -> float:
	return current_weapon.get("range", 60.0)


# ── Characters ────────────────────────────────────────────────────────────────
func select_character(char_id : String) -> void:
	if char_id in unlocked_characters:
		selected_character = char_id
		_init_hearts()
		save()


func unlock_character(char_id : String) -> void:
	if not char_id in unlocked_characters:
		unlocked_characters.append(char_id)
		save()


func get_character_speed() -> float:
	return CHARACTERS.get(selected_character, {}).get("speed", 130.0)


func get_attack_damage() -> int:
	return CHARACTERS.get(selected_character, {}).get("attack_dmg", 1)


func get_attack_speed() -> float:
	return CHARACTERS.get(selected_character, {}).get("attack_spd", 1.0)


# ── Skill tree ────────────────────────────────────────────────────────────────
func is_node_unlocked(char_id : String, node_id : String) -> bool:
	return node_id in skill_tree_nodes.get(char_id, [])


func unlock_skill_node(char_id : String, node_id : String) -> bool:
	var tree : Dictionary = SKILL_TREES.get(char_id, {})
	var node : Dictionary = tree.get(node_id, {})
	if node.is_empty():
		return false
	for req in node.get("requires", []):
		if not is_node_unlocked(char_id, req):
			return false
	var cost : int = node.get("cost", 999)
	if not spend_gold(cost):
		return false
	if not skill_tree_nodes.has(char_id):
		skill_tree_nodes[char_id] = []
	skill_tree_nodes[char_id].append(node_id)
	save()
	return true


func get_ultimate_stats() -> Dictionary:
	var ult_id : String = CHARACTERS.get(selected_character, {}).get("ultimate", "")
	return SPELLS.get(ult_id, {}).duplicate()


func get_spell_stats() -> Dictionary:
	var spell_id : String     = CHARACTERS.get(selected_character, {}).get("spell", "")
	var base     : Dictionary = SPELLS.get(spell_id, {}).duplicate()
	var tree     : Dictionary = SKILL_TREES.get(selected_character, {})
	var unlocked : Array      = skill_tree_nodes.get(selected_character, [])
	for node_id in unlocked:
		var effect : Dictionary = tree.get(node_id, {}).get("effect", {})
		for key in effect:
			if base.has(key):
				base[key] += effect[key]
	return base


# ── Run buffs ─────────────────────────────────────────────────────────────────
func add_run_buff(buff : Dictionary) -> void:
	run_buffs.append(buff)


func get_run_buff(key : String) -> float:
	var total : float = 0.0
	for buff in run_buffs:
		if buff.has(key):
			total += buff[key]
	return total


# ── Tower helpers ─────────────────────────────────────────────────────────────
func select_tower(tower_id : String) -> void:
	if tower_id in unlocked_towers:
		selected_tower = tower_id


func get_tower_name() -> String:
	return TOWERS.get(selected_tower, {}).get("name", "Unknown")


func get_tower_enemy_pool() -> Array:
	return TOWERS.get(selected_tower, {}).get("enemy_pool", [])


func get_tower_floor_count() -> int:
	return TOWERS.get(selected_tower, {}).get("floors", 36)


func is_tower_complete(tower_id : String) -> bool:
	var completed : int = tower_floors_completed.get(tower_id, 0)
	var total     : int = TOWERS.get(tower_id, {}).get("floors", 36)
	return completed >= total


# ── Enemy scaling ─────────────────────────────────────────────────────────────
func get_scaled_enemy(enemy_id : String) -> Dictionary:
	var base       : Dictionary = ENEMIES.get(enemy_id, {}).duplicate()
	var difficulty : float      = get_floor_difficulty()
	base["hp"]     = max(1, int(base.get("hp",     3) * difficulty))
	base["damage"] = max(1, int(base.get("damage", 1) * difficulty))
	base["id"]     = enemy_id
	return base


# ── Save & load ───────────────────────────────────────────────────────────────
func save() -> void:
	var data : Dictionary = {
		"gold"                : gold,
		"selected_character"  : selected_character,
		"unlocked_characters" : unlocked_characters,
		"unlocked_weapons"    : unlocked_weapons,
		"current_weapon"      : current_weapon,
		"skill_tree_nodes"    : skill_tree_nodes,
		"current_floor"            : current_floor,
		"current_room"             : current_room,
		"current_hearts"           : current_hearts,
		"selected_tower"           : selected_tower,
		"unlocked_towers"          : unlocked_towers,
		"tower_floors_completed"   : tower_floors_completed,
	}
	var f := FileAccess.open("user://spire_save.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data))


func load_save() -> void:
	if not FileAccess.file_exists("user://spire_save.json"):
		return
	var f    := FileAccess.open("user://spire_save.json", FileAccess.READ)
	var data  = JSON.parse_string(f.get_as_text())
	if data == null:
		return
	gold                = data.get("gold",                0)
	selected_character  = data.get("selected_character",  "wizard")
	unlocked_characters = data.get("unlocked_characters", ["warrior", "wizard", "healer"])
	unlocked_weapons    = data.get("unlocked_weapons",    ["rusty_sword"])
	current_weapon      = data.get("current_weapon",      {})
	skill_tree_nodes    = data.get("skill_tree_nodes",    {})
	current_floor            = data.get("current_floor",            1)
	current_room             = data.get("current_room",             1)
	current_hearts           = data.get("current_hearts",           get_max_hearts())
	selected_tower           = data.get("selected_tower",           "ashen_keep")
	unlocked_towers          = data.get("unlocked_towers",          ["ashen_keep"])
	tower_floors_completed   = data.get("tower_floors_completed",   {})
	_init_skill_tree()
	if current_weapon.is_empty():
		_init_weapon()
	for cid in ["warrior", "wizard", "healer"]:
		if cid not in unlocked_characters:
			unlocked_characters.append(cid)
