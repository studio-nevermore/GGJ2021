class_name Projectile
extends Area2D

var dying := false

func _physics_process(delta):
	if !dying:
		position.x += 240 * scale.x * delta

func _on_Projectile_body_entered(body):
	if !dying:
		kill()
	
func kill():
	dying = true
	$Sprite.play("dying")

func _on_Sprite_animation_finished():
	if dying:
		queue_free()

func _on_Timer_timeout():
	kill()
