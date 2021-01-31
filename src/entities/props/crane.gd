extends Area2D

var activated := false
var falling := false
var spd := 10.0
var item_spd := 40

var pulsing := false

func _process(delta):
	if !activated:
		$Electricity.visible = pulsing
		
	var p = Global.get_player()
	if !activated and p.global_position.distance_to(global_position) < 20:
		activated = true
		#p.get_node("EventHandler").get_magnetized(self)
		p.get_node("EventHandler").freeze_completely()
		p.visible = false
		event_stuff()
	if falling:
		$AnimatedSprite.position.y += spd * delta
		$Item.position.y += item_spd * delta
		spd += 10
		item_spd += 15

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
	Global.current_room_control.stop_music()
	
	$Timer.start(4)
	yield($Timer, "timeout")
	
	
	Stats.game_data[Stats.Data.glitched] = true
	
	# Change this to go to the proper room when stuff is set up
	Global.current_room_control.room_restart()


func _on_PulseTimer_timeout():
	if !activated:
		if pulsing:
			$PulseTimer.start(1)
			pulsing = false
		else:
			$PulseTimer.start(0.2)
			pulsing = true
