extends Area2D

var activated := false
var falling := false
var spd := 10.0

func _process(delta):
	var p = Global.get_player()
	if !activated and p.global_position.distance_to(global_position) < 20:
		activated = true
		#p.get_node("EventHandler").get_magnetized(self)
		p.get_node("EventHandler").freeze_completely()
		p.visible = false
		event_stuff()
	if falling:
		$AnimatedSprite.position.y += spd * delta
		spd += 10

func event_stuff():
	$AnimatedSprite.visible = true
	$Electricity.visible = true
	Global.current_room_control.get_node("GlitchScreen").glitch_out(1.5)
	$Timer.start()
	yield($Timer, "timeout")
	
	$AnimatedSprite.play("fall")
	$Electricity.visible = false
	falling = true
	$Timer.start(0.5)
	yield($Timer, "timeout")
	
	Global.gui.get_node("ScreenFade").modulate.a = 1
	
	$Timer.start(4)
	yield($Timer, "timeout")
	# Change this to go to the proper room when stuff is set up
	Global.current_room_control.room_restart()
