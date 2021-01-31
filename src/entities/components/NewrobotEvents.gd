class_name RobotEvents
extends EventHandler

var paper_scene = preload("res://src/entities/props/finalpaper.tscn")

func wakeup():
	Global.set_pause_state(Global.PauseState.NORMAL)
	var move = get_parent().get_node("Movement")
	var anim = get_parent().get_node("AnimatedSprite")
	anim.stop = true
	anim.play("sleep")
	
	for w in get_tree().get_nodes_in_group("breakwall"):
		w.queue_free()
		
	$Timer.start(4)
	yield($Timer, "timeout")
	print("b")
	
	anim.stop = false
	move.movement_state = Movement.State.IDLE
	$Timer.start(2)
	yield($Timer, "timeout")
	print("b")
	
	move.facing = Global.HDirs.RIGHT
	$Timer.start(0.5)
	yield($Timer, "timeout")
	move.facing = Global.HDirs.LEFT
	$Timer.start(0.5)
	yield($Timer, "timeout")
	move.facing = Global.HDirs.RIGHT
	$Timer.start(0.5)
	yield($Timer, "timeout")
	move.facing = Global.HDirs.LEFT
	$Timer.start(2)
	yield($Timer, "timeout")
	print("b")
	
	var p = paper_scene.instance()
	Global.current_room.add_child(p)
	p.global_position = Global.VIEW_SIZE / 2
	yield(p, "done")
	$Timer.start(1)
	yield($Timer, "timeout")
	print("b")
	
	move.move_sign = -1
	$Timer.start(3.5)
	yield($Timer, "timeout")
	
	Global.final_cutscene = false
	Global.current_room_control.room_change("title")
