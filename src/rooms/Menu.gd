class_name Menu
extends ColorRect

var current_path = []
var cursor = 0
var lock_input = false
var temp_settings = ["", 0, 0]

var font = preload("res://assets/fonts/Silver.tres")

# name, can_select, settings info
var options_info = {
		"resume": ["Resume", true, []],
		"settings": ["Settings", true, []],
		"resolution": ["Window scale: ", true, [1, 4, Stats.Settings.screen_size]],
		"show_fps": ["Show FPS: ", true, [0, 1, Stats.Settings.show_fps]],
		"music_vol": ["Music Volume: ", true, [0, 10, Stats.Settings.music_vol]],
		"sfx_vol": ["SFX Volume: ", true, [0, 10, Stats.Settings.sfx_vol]],
		"settings_back": ["Back", true, []],
		"quit": ["Quit", true, []],
		"quit_back": ["Back", true, []],
		"quit_to_title": ["Quit to title", true, []],
		"quit_to_desktop": ["Quit game", true, []]
	}

var options_branches = {
		"base": ["resume", "settings", "quit"],
		
		"resume": [],
		
		"settings": ["resolution", "show_fps", "music_vol", "sfx_vol", "settings_back"],
		"resolution": [],
		"show_fps": [],
		"music_vol": [],
		"sfx_vol": [],
		"settings_back": [],
		
		"quit": ["quit_back", "quit_to_title", "quit_to_desktop"],
		"quit_back": [],
		"quit_to_title": [],
		"quit_to_desktop": []
	}

func _ready():
	rect_size = Global.VIEW_SIZE
	
func _process(delta):
	var menu_close_buffer = false
	
	if !lock_input:
		if Global.current_pausestate == Global.PauseState.NORMAL:
			if Input.is_action_just_pressed("ui_menu"):
				Global.set_pause_state(Global.PauseState.PAUSED)
				menu_close_buffer = true
				cursor = 0
				current_path.clear()
				current_path.append("base")
				set_visuals(true)
			
		if Global.current_pausestate == Global.PauseState.PAUSED:
			var point = current_path[-1]
			var options = options_branches[point]
			
			if temp_settings[0] == "":
				if Input.is_action_just_pressed("ui_down"):
					cursor += 1
					if cursor >= options.size():
						cursor = 0
					while !options_info[options[cursor]][1]:
						cursor += 1
						if cursor >= options.size():
							cursor = 0
					set_cursor()
				if Input.is_action_just_pressed("ui_up"):
					cursor -= 1
					if cursor < 0:
						cursor = options.size() - 1
					while !options_info[options[cursor]][1]:
						cursor -= 1
						if cursor < 0:
							cursor = options.size() - 1
					set_cursor()
					
				if Input.is_action_just_pressed("ui_accept"):
					var new_options = options_branches[options[cursor]]
					if new_options != []:
						current_path.append(options[cursor])
						cursor = 0
						while !options_info[new_options[cursor]][1]:
							cursor += 1
						set_visuals(true)
						
					else:
						match options[cursor]:
							"resume", "settings_back", "quit_back":
								cursor = 0
								current_path.pop_back()
								if current_path.size() == 0:
									Global.set_pause_state(Global.PauseState.NORMAL)
								else:
									set_visuals(true)
							"quit_to_title":
								lock_input = true
								Global.current_room_control.room_change("misc/title")
							"quit_to_desktop":
								lock_input = true
								Global.current_room_control.game_end()
							
							_:
								var settingsinfo = options_info[options[cursor]][2]
								if settingsinfo.size() > 0:
									temp_settings = [options[cursor], Stats.game_settings[settingsinfo[2]], Stats.game_settings[settingsinfo[2]]]
									set_visuals()
				
				if Input.is_action_just_pressed("ui_cancel"):
					cursor = 0
					current_path.pop_back()
					if current_path.size() == 0:
						Global.set_pause_state(Global.PauseState.NORMAL)
					else:
						set_visuals(true)
					
			else:
				if Input.is_action_just_pressed("ui_accept"):
					temp_settings[0] = ""
					set_visuals()
					DataManager.settings_save()
					
				if Input.is_action_just_pressed("ui_cancel"):
					set_setting(temp_settings[2])
					temp_settings[0] = ""
					set_visuals()
					
				if Input.is_action_just_pressed("ui_left"):
					temp_settings[1] -= 1
					if temp_settings[1] < options_info[temp_settings[0]][2][0]:
						temp_settings[1] = options_info[temp_settings[0]][2][1]
					set_setting(temp_settings[1])
					set_visuals()
				if Input.is_action_just_pressed("ui_right"):
					temp_settings[1] += 1
					if temp_settings[1] > options_info[temp_settings[0]][2][1]:
						temp_settings[1] = options_info[temp_settings[0]][2][0]
					set_setting(temp_settings[1])
					set_visuals()
					
			if Input.is_action_just_pressed("ui_menu") and !menu_close_buffer:
				Global.set_pause_state(Global.PauseState.NORMAL)
	visible = Global.current_pausestate == Global.PauseState.PAUSED

func set_visuals(reload_nodes = false):
	var point = current_path[-1]
	var options = options_branches[point]
	
	if reload_nodes:
		for c in get_children():
			if c is Label:
				c.free()
		
		for i in range(options.size()):
			var l = Label.new()
			add_child(l)
			l.align = Label.ALIGN_CENTER
			l.valign = Label.ALIGN_CENTER
			l.rect_position = Global.VIEW_SIZE / 2
			var center_index = float(options.size()) / 2 - 0.5
			var sep = 40
			sep += 10 * min(4 - options.size(), 0)
			l.rect_position.y -= sep * (center_index - i)
			l.rect_size = Vector2(300, 50)
			l.rect_position -= l.rect_size / 2
			l.add_font_override("font", font)
			
	var i = 0
	for c in get_children():
		if c is Label:
			if i < options.size():
				c.text = options_info[options[i]][0]
				if temp_settings[0] != "" and i == cursor:
					c.modulate = Color(0.6, 0.35, 0.7)
				else:
					c.modulate = Color(1, 1, 1)
				
				var val = temp_settings[1]
				if options_info[options[i]][2].size() > 0:
					val = Stats.game_settings[options_info[options[i]][2][2]]
				match options[i]:
					"music_vol", "sfx_vol":
						c.text += str(val)
					"resolution":
						c.text += str(val) + "x"
					"show_fps":
						if val == 0:
							c.text += "Off"
						else:
							c.text += "On"
				i += 1
			else:
				break
				
	set_cursor()

func set_cursor():
	var i = 0
	for c in get_children():
		if c is Label:
			if i == cursor:
				$Cursor0.position = c.rect_position + c.rect_size / 2
				$Cursor0.position.y -= 2
				$Cursor1.position = $Cursor0.position
				
				#var halfsize = (c.text.length() / 2) * 11
				$Cursor0.position.x -= 70
				$Cursor1.position.x += 70
				break
			i += 1

func set_setting(val):
	var point = current_path[-1]
	Stats.set_setting(options_info[options_branches[point][cursor]][2][2], val)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
