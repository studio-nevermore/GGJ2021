class_name GlitchScreen
extends CanvasLayer

signal glitch_over

func glitch_out(time = 0.5):
	$Timer.start(time)
	$ColorRect.material.set_shader_param("AMPLITUDE", 1)

func _on_Timer_timeout():
	$ColorRect.material.set_shader_param("AMPLITUDE", 0)
	emit_signal("glitch_over")
