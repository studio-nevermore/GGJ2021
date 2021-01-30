class_name PlayerPhysics
extends Node2D

export(Resource) var Physics

export(int) var extra_jumps = 0

# jump_action returns true if movement is allowed to perform an actual jump
func jump_action() -> bool:
	return true
