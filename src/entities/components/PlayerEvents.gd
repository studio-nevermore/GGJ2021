extends EventHandler

func freeze_movement():
	var pmove = parent.get_node("Movement")
	if pmove:
		pmove._velocity.x = 0
		pmove.move_sign = 0
	parent.get_node("PlayerControls").controls_disabled = true

func unfreeze_movement():
	parent.get_node("PlayerControls").controls_disabled = false

func freeze_completely():
	var pmove = parent.get_node("Movement")
	if pmove:
		pmove._velocity = Vector2.ZERO
		pmove.move_sign = 0
		pmove.freeze_gravity = true
	parent.get_node("PlayerControls").controls_disabled = true
	
func unfreeze_completely():
	var pmove = parent.get_node("Movement")
	if pmove:
		pmove.freeze_gravity = false
	parent.get_node("PlayerControls").controls_disabled = false
