extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("game_jump"):
		Global.current_room_control.room_change(Stats.rooms[Stats.game_data[Stats.Data.room]], false)
