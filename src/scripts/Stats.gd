extends Node

enum Settings {
	screen_size,
	show_fps,
	music_vol,
	sfx_vol
}

enum Data {
	version,
	room,
	checkpoint,
	
	upgrade_jump,
	upgrade_jump2,
	upgrade_speed,
	upgrade_melee,
	
	upgrade_map,
	upgrade_projectile,
	upgrade_swim,
	upgrade_magnet,
	
	glitched,
	
	map_cells,
	
	glitch_seed = 50,
	flags = 100
}

enum Flags {
	none
}

signal screen_set()

const data_version = 2

var game_data := []
var game_settings := []

var player_direction = Global.HDirs.RIGHT

var rooms = [
		"map/A1",
		"map/A2",
		"map/A3",
		"map/A4",
		"map/B1",
		"map/B2",
		"map/B3",
		"map/B4",
		"map/C1",
		"map/C2",
		"map/C3",
		"map/C4",
		"map/D1",
		"map/D2",
		"map/D3",
		"map/D4"
	]
var room_prefix = "src/rooms/stages/"
var room_suffix = ".tscn"

func _ready():
	DataManager.data_load()
	DataManager.settings_load()

func set_flag(flag, ind = 1):
	game_data[Data.flags + flag] = ind
	
func get_flag(flag):
	return game_data[Data.flags + flag]

func initialize_data():
	game_data.clear()
	while game_data.size() < 200:
		game_data.append(0)
		
	game_data[Data.version] = data_version
	game_data[Data.room] = 10
	game_data[Data.checkpoint] = 5
	
func initialize_settings():
	game_settings.clear()
	while game_settings.size() < Settings.size():
		game_settings.append(0)
		
	game_settings[Settings.screen_size] = 2
	game_settings[Settings.show_fps] = 0
	game_settings[Settings.music_vol] = 8
	game_settings[Settings.sfx_vol] = 8
	
	set_all_settings()

func set_setting(setting, val = null, set_in_data = true):
	if val != null and set_in_data:
		game_settings[setting] = val
	if !val:
		val = game_settings[setting]
	
	match setting:
		Stats.Settings.screen_size:
			temp_set_screen()
		Stats.Settings.music_vol:
			set_volume(AudioServer.get_bus_index("Music"), val)
		Stats.Settings.sfx_vol:
			set_volume(AudioServer.get_bus_index("SFX"), val)

func set_volume(bus, volume):
	var amp = float(volume) / 10.0
	amp = Global.scale_range_to(amp, 0.000001, 1)
	var db = (log(amp) / log(10)) * 20

	AudioServer.set_bus_volume_db(bus, db)
	AudioServer.set_bus_mute(bus, volume == 0)

func set_all_settings():
	var i = 0
	for s in game_settings:
		set_setting(i)
		i += 1

func temp_set_screen() -> void:
	OS.set_window_size(Vector2(game_settings[Settings.screen_size] * Global.VIEW_SIZE.x * 2, game_settings[Settings.screen_size] * Global.VIEW_SIZE.y * 2))
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)
	emit_signal("screen_set")
