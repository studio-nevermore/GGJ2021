class_name Player
extends Entity

var dying := false
var last_ground := Vector2.ZERO

func _ready():
	add_to_group("player")
	
func _process(delta):
	if dying:
		$PlayerControls.controls_disabled = true
		
	if Input.is_action_just_pressed("debug_1"):
		Stats.game_data[Stats.Data.upgrade_jump] = 1
		Stats.game_data[Stats.Data.upgrade_jump2] = 1
		Stats.game_data[Stats.Data.upgrade_speed] = 1
	if Input.is_action_just_pressed("debug_2"):
		Stats.game_data[Stats.Data.upgrade_swim] = 1
		Stats.game_data[Stats.Data.upgrade_magnet] = 1
	if Input.is_action_just_pressed("debug_3"):
		Stats.game_data[Stats.Data.upgrade_melee] = 1
		Stats.game_data[Stats.Data.upgrade_projectile] = 1
	
func set_depth() -> void:
	pass
	
func _can_drop_through_platform() -> bool:
	for i in range(get_slide_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision.collider.get_collision_layer_bit(Global.CollisionLayers.ENVIRONMENT_ONE_WAY):
			return true
	return false

func move_with_camera_snap(new_pos):
	global_position = new_pos

func _on_Movement_movement_state_changed(old_state, new_state):
	pass
