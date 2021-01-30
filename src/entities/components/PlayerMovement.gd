class_name PlayerMovement
extends Movement

var normal_node: PlayerPhysics
var water_node: PlayerPhysics

#var space_state

func _ready():
	for ch in get_children():
		if ch.name == "WaterPhysics":
			water_node = ch
		if ch.name == "NormalPhysics":
			normal_node = ch

func _physics_process(delta):
	#if get_parent().is_in_water:
	#	Physics = water_node.Physics
	#else:
	Physics = normal_node.Physics
