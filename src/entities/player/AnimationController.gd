class_name AnimationController
extends AnimatedSprite

var floortime := false
var stop := false

var blinkframe := 0

func _process(delta):
	if !get_parent().is_on_floor():
		floortime = true
		
	if get_node_or_null("BlinkTimer"):
		$Blink.frame = blinkframe

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
				
		set_blink()

func _on_Movement_facing_changed(previous, new):
	if new == Global.HDirs.LEFT:
		scale.x = -1
	else:
		scale.x = 1

func _on_Animations_frame_changed():
	set_blink()
	
func set_blink():
	$Blink.visible = true
	var off = 0
	match animation:
		"idle", "swim":
			if frame == 0:
				off = 0
			else:
				off = 1
		"walk":
			if frame == 0:
				off = -1
			else:
				off = 0
		"jump":
			off = -1
		"hurt", "wakeup", "sleep", "whatever":
			$Blink.visible = false
	$Blink.offset.y = off

func _on_BlinkTimer_timeout():
	match blinkframe:
		0:
			$BlinkTimer.start(0.1 + rand_range(0, 0.1))
			blinkframe = 1
		1:
			$BlinkTimer.start(0.5 + rand_range(0, 8))
			blinkframe = 0

