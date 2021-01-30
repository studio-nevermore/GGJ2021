class_name RoomBoundary
extends Area2D

var entrances := []

func _ready():
	for e in get_tree().get_nodes_in_group("boundaryentrance"):
		entrances.append(e)

func move_player():
	var p = Global.get_player()
	
	if Global.current_boundary_entrance == -1:
		var closest
		for e in get_tree().get_nodes_in_group("boundaryentrance"):
			if !closest:
				closest = e
			elif p.global_position.distance_to(e.global_position) < p.global_position.distance_to(closest.global_position):
				closest = e
		Global.current_boundary_entrance = closest.entrance
			
	for e in get_tree().get_nodes_in_group("boundaryentrance"):
		if e.entrance == Global.current_boundary_entrance:
			#var face = Global.HDirs.RIGHT
			#if sign(e.scale.x) == -1:
			#	face = Global.HDirs.LEFT
			#p.get_node("Movement").facing = face
			p.move_with_camera_snap(e.global_position)
			break
	
func _on_Timer_timeout():
	Global.entity_active = true
	Global.get_player().get_node("Movement").freeze_movement = false

func _on_RoomBoundary_body_exited(body):
	pass #Room transition code

