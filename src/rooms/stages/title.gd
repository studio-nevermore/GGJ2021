extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("game_jump"):
		Global.start_from_save = true
		Global.current_room_control.room_change(Stats.rooms[Stats.game_data[Stats.Data.room]], false)
	if Global.gui.get_node("ScreenFade").modulate.a == 0:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("wobble")
