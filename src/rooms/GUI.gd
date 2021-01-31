class_name GUI
extends Node2D

signal fade_finished(out)

var fade := 0

func _init():
	Global.gui = self

func _ready():
	Stats.connect("screen_set", self, "on_screen_set")
	$ScreenFade.visible = true

func _process(delta):
	var view = get_viewport()
	global_position = -view.canvas_transform.origin
	
	if !$ScreenFade/AnimationPlayer.is_playing():
		if fade == -1:
			emit_signal("fade_finished", true)
		if fade == 1:
			emit_signal("fade_finished", false)
		fade = 0
		
	if Stats.game_settings.size() > 0:
		$FPS.visible = true if Stats.game_settings[Stats.Settings.show_fps] == 1 else false
		$FPS.text = str(round(Engine.get_frames_per_second()))
		$FPSBack.visible = $FPS.visible
		$FPSBack.text = $FPS.text

func fade_screen(out = true, spd = 1):
	var fadenode = $ScreenFade/AnimationPlayer
	var current_pos = -1
	
	if ($ScreenFade.modulate.a == 1 and out) or ($ScreenFade.modulate.a == 0 and !out):
		emit_signal("fade_finished", out)
		fadenode.stop()
	else:
			
		if fadenode.is_playing():
			current_pos = fadenode.current_animation_position
		
		if out:
			fadenode.play("unfade", -1, -1, true)
		else:
			fadenode.play("unfade")
			
		fadenode.playback_speed = spd
		
		if current_pos >= 0:
			fadenode.seek(current_pos, true)
			
		if out:
			fade = -1
		else:
			fade = 1
			
func on_screen_set():
	var view = get_viewport()
	global_position = -view.canvas_transform.origin
