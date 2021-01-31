class_name Room
extends Node2D

export(bool) var has_player = false
export(Vector2) var map_cell = Vector2(-1, -1)
export(String) var scene_path = ""

var dir = "src/rooms/stages/"
var ext = ".tscn"
var music_started := false
var music_fading := -1.0

var stage_music := ["Music"]

func _ready():
	Global.gui.connect("fade_finished", self, "fadetimer_over")
	if Global.gui.get_node("ScreenFade").modulate.a == 1:
		if scene_path == "title":
			Global.gui.fade_screen(false, 0.25)
		else:
			Global.gui.fade_screen(false)
	else:
		fadetimer_over(false)
	
	Global.current_room = get_parent()
	Global.current_room_control = self
	Global.current_room_path = scene_path
	
	Global.set_pause_state(Global.PauseState.NORMAL)
	Global.gui.get_node("Menu").lock_input = false
	
	if has_player:
		Global.get_player().get_node("Movement").facing = Stats.player_direction
		
	if map_cell != Vector2(-1, -1):
		Stats.game_data[Stats.Data.map_cells + map_cell.x + map_cell.y * 4] = 1
		SceneManager.game_view.get_node("GUI/Map").selected_cell = map_cell
		
		if Global.current_boundary_entrance != -1:
			Stats.game_data[Stats.Data.checkpoint] = Global.current_boundary_entrance
		else:
			Global.current_boundary_entrance = Stats.game_data[Stats.Data.checkpoint]
			
		var ind = Stats.rooms.find(scene_path)
		if ind != -1:
			Stats.game_data[Stats.Data.room] = ind
			
		DataManager.data_save()
	else:
		Global.current_boundary_entrance = -1
	
	
	reready()
	
	if !Global.start_from_save:
		_on_Timer_timeout()
	else:
		$Timer.start()

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
	
func room_change(path, is_stage = true):
	Global.set_pause_state(Global.PauseState.EVENT)
	if has_player:
		Global.get_player().get_node("PlayerControls").fade_buffer = true
	if !is_stage or !Stats.game_data[Stats.Data.glitched]:
		fadeout()
		yield(Global.gui, "fade_finished")
	else:
		$ExitTimer.start()
		yield($ExitTimer, "timeout")
		$GlitchScreen.glitch_out()
		yield($GlitchScreen, "glitch_over")
	room_end()
	
	if Stats.game_data[Stats.Data.glitched] and path != "title":
		# Room shuffling stuff, pick actual room based on path and stats room index
		pass
	
	SceneManager.load_scene("stages/" + path)
	
func game_end():
	fadeout()
	yield(Global.gui, "fade_finished")
	room_end()
	get_tree().quit()

func room_end():
	if Global.current_room == get_parent():
		Global.current_room = null
		Global.current_room_control = null

func fadeout():
	if scene_path == "title":
		Global.gui.fade_screen(true, 0.25)
	else:
		Global.gui.fade_screen(true)

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
	
	if map_cell != Vector2(-1, -1):
		move_player()
		
		if has_player and Global.start_from_save:
			Global.get_player().get_node("EventHandler").wake_up()
			
	Global.start_from_save = false

func move_player():
	var p = Global.get_player()
	
	if Global.current_boundary_entrance == -1:
		var closest
		for e in get_tree().get_nodes_in_group("boundaryentrance"):
			if !closest:
				closest = e
			elif p.global_position.distance_to(e.global_position) < p.global_position.distance_to(closest.global_position):
				closest = e
		
		var face = Global.HDirs.RIGHT
		if sign(closest.scale.x) == -1:
			face = Global.HDirs.LEFT
		p.get_node("Movement").facing = face
		p.move_with_camera_snap(closest.global_position)
				
	else:
		var closest
		for e in get_tree().get_nodes_in_group("boundaryentrance"):
			if e.entrance_index == Global.current_boundary_entrance:
				var face = Global.HDirs.RIGHT
				if sign(e.scale.x) == -1:
					face = Global.HDirs.LEFT
				p.get_node("Movement").facing = face
				p.move_with_camera_snap(e.global_position)
				break

func fadetimer_over(out):
	if !out and !music_started:
		if SceneManager.game_view:
			play_music("")
			music_started = true
		#$Music.playing = true
	if has_player:
		Global.get_player().get_node("PlayerControls").fade_buffer = false
