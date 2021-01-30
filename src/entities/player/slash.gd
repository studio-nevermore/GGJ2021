class_name Slash
extends Area2D

func _ready():
	$Sprite.playing = true

func _on_Sprite_animation_finished():
	queue_free()
