extends Sprite

signal done

func _ready():
	$AnimationPlayer.play("appear")

func _process(delta):
	if !$AnimationPlayer.is_playing() and Input.is_action_just_pressed("game_jump"):
		$AnimationPlayer.play("disappear")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "disappear":
		emit_signal("done")
		queue_free()
