class_name ExplodeEffect
extends AnimatedSprite

func _ready():
	playing = true

func _on_ExplodeEffect_animation_finished():
	queue_free()
