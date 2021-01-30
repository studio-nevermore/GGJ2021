class_name PlayerMovement
extends Movement

var normal_node: PlayerPhysics
var water_node: PlayerPhysics

var space_state

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
	
	space_state = get_world_2d().direct_space_state
	if Parent.is_on_floor() and space_state.intersect_ray(Vector2(Parent.global_position.x + 24 * sign(_velocity.x), Parent.global_position.y), Vector2(Parent.global_position.x + 24 * sign(_velocity.x), Parent.global_position.y + 15), [self, Parent], Parent.collision_mask):
		Parent.last_ground = Parent.global_position
