class_name BoundaryExit
extends Area2D

export(String) var exit_room = ""
export(String) var exit_room_glitched = ""
export(Global.Dirs) var exit_direction = Global.Dirs.LEFT
export(int) var entrance_index = 0

func _on_BoundaryExit_body_entered(body):
	var move = body.get_node("Movement")
	match exit_direction:
		Global.Dirs.LEFT:
			move.move_sign = -1
		Global.Dirs.RIGHT:
			move.move_sign = 1
		Global.Dirs.UP:
			move._velocity = Vector2(0, -move.Physics.max_run_speed)
			move.movement_state = Movement.State.JUMPING
			move.bypass_physics = true
		Global.Dirs.DOWN:
			move._velocity = Vector2(0, move.Physics.max_run_speed)
			move.movement_state = Movement.State.JUMPING
			move.bypass_physics = true
	
	Global.get_player().get_node("PlayerControls").controls_disabled = true
	
	Global.current_boundary_entrance = entrance_index

	if Stats.game_data[Stats.Data.glitched]:
		exit_room = exit_room_glitched
	if exit_room != "":
		Global.current_room_control.room_change(exit_room)
	else:
		Global.current_room_control.room_restart()
