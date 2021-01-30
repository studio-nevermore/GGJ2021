class_name AnimationController
extends AnimatedSprite

func _process(delta):
	$Hat.offset.x = offset.x

func _on_Movement_movement_state_changed(previous, new):
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
	if a:
		play(a)

func _on_Movement_facing_changed(previous, new):
	if new == Global.HDirs.LEFT:
		scale.x = -1
	else:
		scale.x = 1
