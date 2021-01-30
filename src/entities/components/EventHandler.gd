class_name EventHandler
extends Node2D

signal input_received()

onready var parent = get_parent()
	
func move_towards_point(pos: Vector2, freeze_at_end: bool = true) -> bool:
	var pmove = parent.get_node("Movement")
	if !pmove:
		$Timer.start(Global.ONE_FRAME)
		yield($Timer, "timeout")
		return false
	else:
		while parent.position.distance_to(pos) > 5:
			pmove.move_direction = Global.rad2vector(pos.angle_to_point(parent.position))
			yield(get_tree(), "physics_frame")
		parent.position = pos
		pmove.move_direction = Vector2.ZERO
		if freeze_at_end:
			pmove.freeze()
		$Timer.start(Global.ONE_FRAME)
		yield($Timer, "timeout")
		return true

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("input_received")

func camera_fade(spd: float, out: bool) -> void:
	Global.get_camera().camera_fade(spd, out)
	yield(Global.get_camera(), "fade_finished")
