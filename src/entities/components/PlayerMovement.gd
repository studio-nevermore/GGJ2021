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
	pass
	#space_state = get_world_2d().direct_space_state
	#if get_parent().is_in_water:
	#	Physics = water_node.Physics
	#else:
	#	Physics = normal_node.Physics

#func _jump(velocity: Vector2, delta: float, override_check: bool = false) -> void:
#	# need to assign this here because _jumping can be modified prior to this
#	var moveJump :=  not drop and (beginJump or (_jumping and holdJump))
#	pass
