class_name Room
extends Node2D

export(bool) var is_stage = false
export(bool) var has_player = false
export(String) var scene_path = ""

var dir = "src/rooms/"
var ext = ".tscn"
var music_started := false
var music_fading := -1.0

var stage_music := ["Music"]

func _ready():
	Global.gui.connect("fade_finished", self, "fadetimer_over")
	Global.gui.fade_screen(false)
	
	Global.current_room = get_parent()
	Global.current_room_control = self
	Global.current_room_path = scene_path
	
	Global.set_pause_state(Global.PauseState.NORMAL)
	Global.gui.get_node("Menu").lock_input = false
	
	if has_player:
		Global.get_player().get_node("Movement").facing = Stats.player_direction
	
	reready()

func reready():
	Global.gui.global_position = Vector2.ZERO
	get_viewport().canvas_transform.origin = Vector2.ZERO

func _process(delta):
	if music_fading != -1:
		var game_music = SceneManager.game_view.get_node("Music")
		if game_music.playing:
			music_fading -= 0.01
			if music_fading > 0:
				Stats.set_setting(Stats.Settings.music_vol, Stats.game_settings[Stats.Settings.music_vol] * music_fading, false)
			else:
				game_music.playing = false
				Stats.set_setting(Stats.Settings.music_vol)
		else:
			music_fading = -1


func room_restart(from_save = false):
	Global.start_from_save = from_save
	
	room_change(Global.current_room_path)
	
func room_change(path):
	Global.set_pause_state(Global.PauseState.EVENT)
	if has_player:
		Global.get_player().get_node("PlayerControls").fade_buffer = true
	fadeout()
	yield(Global.gui, "fade_finished")
	room_end()
	
	SceneManager.load_scene(path)
	
func game_end():
	fadeout()
	yield(Global.gui, "fade_finished")
	room_end()
	get_tree().quit()

func room_end():
	if Global.current_room == get_parent():
		Global.current_room = null
		Global.current_room_control = null
		
	DataManager.data_save()

func fadeout():
	Global.gui.fade_screen()

func play_music(trackname):
	if trackname == "":
		trackname = stage_music[Global.stage_music_level]
	var n = get_node_or_null(trackname)
	if n and n.stream:
		set_music(trackname)
		var game_music = SceneManager.game_view.get_node("Music")
		if !game_music.playing:
			game_music.playing = true

func set_music(trackname):
	if trackname == "":
		trackname = stage_music[Global.stage_music_level]
	music_fading = -1
	Stats.set_setting(Stats.Settings.music_vol)
	var n = get_node_or_null(trackname)
	if n and n.stream:
		var game_music = SceneManager.game_view.get_node("Music")
		if !game_music.stream or game_music.stream.data != n.stream.data:
			game_music.stream = n.stream
			game_music.playing = false
			
func stop_music():
	var game_music = SceneManager.game_view.get_node("Music")
	game_music.playing = false
	music_fading = -1
	Stats.set_setting(Stats.Settings.music_vol)
	
func fade_music():
	music_fading = 1

func _on_Timer_timeout():
	DataManager.settings_load()
	
	set_music("")
	
	for b in get_tree().get_nodes_in_group("roomboundary"):
		if b is RoomBoundary:
			b.move_player()
			break

func fadetimer_over(out):
	if !out and !music_started:
		if SceneManager.game_view:
			play_music("")
			music_started = true
		#$Music.playing = true
	if has_player:
		Global.get_player().get_node("PlayerControls").fade_buffer = false
