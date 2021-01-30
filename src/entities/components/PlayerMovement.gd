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
	if Stats.game_data[Stats.Data.upgrade_jump]:
		normal_node.Physics.jump_height = 3.5
	if Stats.game_data[Stats.Data.upgrade_speed]:
		normal_node.Physics.max_run_speed = 14
		normal_node.Physics.decel_run = 60
		
	Physics = normal_node.Physics
