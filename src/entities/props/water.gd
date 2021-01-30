class_name Water
extends Area2D

func _on_Water_body_entered(body):
	if body.is_in_group("player"):
		if !Stats.game_data[Stats.Data.upgrade_swim]:
			body.get_node("EventHandler").freeze_completely()
			body.get_node("Animations").play("hurt")
			$Timer.start()
		else:
			body.get_node("Movement").freeze_gravity = true
			body.get_node("Movement").movement_state = Movement.State.SWIMMING

func _on_Timer_timeout():
	var p = Global.get_player()
	p.global_position = p.last_ground
	p.get_node("EventHandler").unfreeze_completely()


func _on_Water_body_exited(body):
	if body.is_in_group("player"):
		body.get_node("Movement").freeze_gravity = false
		body.get_node("Movement").movement_state = Movement.State.IDLE
