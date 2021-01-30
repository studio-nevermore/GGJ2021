class_name AnimationController
extends AnimatedSprite

var floortime := false
var stop := false

func _process(delta):
	if !get_parent().is_on_floor():
		floortime = true

func _on_Movement_movement_state_changed(previous, new):
	if !stop:
		var a
		match new:
			Movement.State.IDLE:
				a = "idle"
			Movement.State.RUNNING:
				a = "walk"
			Movement.State.JUMPING:
				a = "jump"
			Movement.State.FALLING:
				a = "jump"
			Movement.State.HITSTUN:
				a = "hurt"
			Movement.State.DEATH:
				a = "death"
			Movement.State.SWIMMING:
				a = "swim"
		if a:
			play(a)
			
		if floortime and get_parent().is_on_floor():
			floortime = false
			if new == Movement.State.RUNNING:
				frame = 1

func _on_Movement_facing_changed(previous, new):
	if new == Global.HDirs.LEFT:
		scale.x = -1
	else:
		scale.x = 1
