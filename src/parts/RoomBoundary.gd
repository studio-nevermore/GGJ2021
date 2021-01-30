class_name RoomBoundary
extends Area2D

var entrances := []

export(Dictionary) var connected_rooms = {
	"Left": "",
	"Right": "",
	"Up": "",
	"Down": ""
}
var new_room := ""
var can_leave := false

func _ready():
	for e in get_tree().get_nodes_in_group("boundaryentrance"):
		entrances.append(e)

func move_player():
	var p = Global.get_player()
	
	if Global.boundary_exit_side == -1:
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
		var target_side = Global.Dirs.LEFT
		match Global.boundary_exit_side:
			Global.Dirs.LEFT:
				target_side = Global.Dirs.RIGHT
				Global.boundary_exit_pos.x = $CollisionShape2D.shape.extents.x * 2 * scale.x
			Global.Dirs.RIGHT:
				target_side = Global.Dirs.LEFT
				Global.boundary_exit_pos.x = 0
			Global.Dirs.UP:
				target_side = Global.Dirs.DOWN
				Global.boundary_exit_pos.y = $CollisionShape2D.shape.extents.y * 2 * scale.y
			Global.Dirs.DOWN:
				target_side = Global.Dirs.UP
				Global.boundary_exit_pos.y = 0
				
		var closest
		for e in get_tree().get_nodes_in_group("boundaryentrance"):
			if e.side == target_side:
				if !closest:
					closest = e
				elif Global.boundary_exit_pos.distance_to(e.global_position) < Global.boundary_exit_pos.distance_to(closest.global_position):
					closest = e
					
		var face = Global.HDirs.RIGHT
		if sign(closest.scale.x) == -1:
			face = Global.HDirs.LEFT
		p.get_node("Movement").facing = face
		p.move_with_camera_snap(closest.global_position)
		
	
func _on_Timer_timeout():
	can_leave = true
	#Global.entity_active = true
	#Global.get_player().get_node("Movement").freeze_movement = false

func ExitRoom(dir):
	Global.boundary_exit_side = dir
	Global.boundary_exit_pos = Global.get_player().global_position
	
	Global.get_player().get_node("PlayerControls").controls_disabled = true
	
	if new_room != "":
		Global.current_room_control.room_change("stages/" + new_room)
	else:
		Global.current_room_control.room_restart()

func LeftExit(body):
	if can_leave:
		new_room = connected_rooms["Left"]
		var move = body.get_node("Movement")
		move.move_sign = -1
		ExitRoom(Global.Dirs.LEFT)

func RightExit(body):
	if can_leave:
		new_room = connected_rooms["Right"]
		var move = body.get_node("Movement")
		move.move_sign = 1
		ExitRoom(Global.Dirs.RIGHT)

func UpExit(body):
	if can_leave:
		new_room = connected_rooms["Up"]
		var move = body.get_node("Movement")
		move._velocity = Vector2(0, -move.Physics.max_run_speed)
		move.movement_state = Movement.State.JUMPING
		move.bypass_physics = true
		ExitRoom(Global.Dirs.UP)

func DownExit(body):
	if can_leave:
		new_room = connected_rooms["Down"]
		var move = body.get_node("Movement")
		move._velocity = Vector2(0, move.Physics.max_run_speed)
		move.movement_state = Movement.State.JUMPING
		move.bypass_physics = true
		ExitRoom(Global.Dirs.DOWN)
