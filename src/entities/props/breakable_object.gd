class_name BreakableObject
extends StaticBody2D

var explode_scene = preload("res://src/entities/props/explode.tscn")
export(int) var hp = 5
var dying := false

func _process(delta):
	if !dying:
		if material:
			material.set_shader_param("color", Color(0.35, 0.55, 0.6))
			if !$AnimationPlayer.is_playing():
				material.set_shader_param("intensity", 0)

func _on_Hurtbox_area_entered(area):
	hp -= 1
	if hp <= 0:
		var explode = explode_scene.instance()
		var dying = true
		Global.current_room.add_child(explode)
		explode.global_position = global_position
		queue_free()
	else:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("shake")
		$ShakeTimer.start()

func _on_ShakeTimer_timeout():
	if !dying:
		$AnimationPlayer.stop()
