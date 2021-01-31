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
	if pmove:
		pmove._velocity = Vector2.ZERO
		pmove.move_sign = 0
		pmove.freeze_gravity = true
	parent.get_node("PlayerControls").controls_disabled = true
	parent.get_node("Animations").stop = true
	
func unfreeze_completely():
	var pmove = parent.get_node("Movement")
	if pmove:
		pmove.freeze_gravity = false
	parent.get_node("PlayerControls").controls_disabled = false
	parent.get_node("Animations").stop = false

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
