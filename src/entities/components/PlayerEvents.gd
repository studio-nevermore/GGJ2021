extends EventHandler

func freeze_movement():
	var pmove = parent.get_node("Movement")
	if pmove:
		pmove._velocity.x = 0
		pmove.move_sign = 0
	parent.get_node("PlayerControls").controls_disabled = true

func unfreeze_movement():
	parent.get_node("PlayerControls").controls_disabled = false

func freeze_completely():
	var pmove = parent.get_node("Movement")
	pmove._velocity = Vector2.ZERO
	pmove.move_sign = 0
	pmove.freeze_gravity = true
	parent.get_node("PlayerControls").controls_disabled = true
	parent.get_node("Animations").stop = true
	
func unfreeze_completely():
	var pmove = parent.get_node("Movement")
	pmove.freeze_gravity = false
	parent.get_node("PlayerControls").controls_disabled = false
	parent.get_node("Animations").stop = false

func wake_up():
	Global.set_pause_state(Global.PauseState.EVENT)
	freeze_movement()
	var panims = parent.get_node("Animations")
	panims.stop = true
	panims.play("sleep")
	
	$Timer.start(1)
	yield($Timer, "timeout")
	
	panims.play("wakeup")
	yield(panims, "animation_finished")
	
	$Timer.start(0.3)
	yield($Timer, "timeout")
	
	unfreeze_movement()
	panims.stop = false
	Global.set_pause_state(Global.PauseState.NORMAL)

func get_magnetized(body):
	Global.set_pause_state(Global.PauseState.EVENT)
	freeze_movement()
	var pmove = parent.get_node("Movement")
	var panims = parent.get_node("Animations")
	pmove.facing = Global.HDirs.RIGHT
	
	$Timer.start(1)
	yield($Timer, "timeout")

	panims.stop = true
	pmove.bypass_physics = true
	pmove._velocity.x = 20
	$Timer.start(1)
	yield($Timer, "timeout")
	
	pmove._velocity.x = 10
	pmove.facing = Global.HDirs.LEFT
	panims.play("walk")
	$Timer.start(1.5)
	yield($Timer, "timeout")
	
	pmove._velocity.x = 5
	panims.play("hurt")
	$Timer.start(1.5)
	yield($Timer, "timeout")
	
	pmove._velocity = Global.rad2vector(parent.global_position.angle_to_point(body.global_position))
	$Timer.start(0.5)
	yield($Timer, "timeout")
	
	parent.visible = false
	body.event_stuff()

func end_event():
	Global.set_pause_state(Global.PauseState.EVENT)
	freeze_movement()
	
	var pmove = parent.get_node("Movement")
	var panims = parent.get_node("Animations")
	var parts = parent.get_node("LightParticles")
	pmove.facing = Global.HDirs.RIGHT
	
	Global.current_room_control.fade_music()
	$Timer.start(2)
	yield($Timer, "timeout")
	
	panims.stop = true
	panims.play("whatever")
	parent.z_index = 75
	$Timer.start(0.4)
	yield($Timer, "timeout")
	
	parts.emitting = true
	$Timer.start(1)
	yield($Timer, "timeout")
	
	parts.amount = 8
	parent.get_node("AnimationPlayer2").play("shake")
	$Timer.start(1.5)
	yield($Timer, "timeout")
	
	parts.amount = 14
	$Timer.start(1.5)
	yield($Timer, "timeout")
	
	parts.spread = 60
	$Timer.start(1.5)
	yield($Timer, "timeout")
	
	parent.get_node("AnimationPlayer").play("white")
	yield(parent.get_node("AnimationPlayer"), "animation_finished")
	
	Global.gui.get_node("LightScreen/AnimationPlayer").play("fade")
	
	Global.final_cutscene = true
	Global.current_room_control.room_restart()
	
