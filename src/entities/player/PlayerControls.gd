class_name PlayerControls
extends Node2D

export(float) var max_sens := 0.9
var MovementController

var fade_buffer := true
var controls_disabled := false

var slash_scene = preload("res://src/entities/player/slash.tscn")
var projectile_scene = preload("res://src/entities/player/projectile.tscn")
var last_slash_up := false
var magnetized := false
var magnetized_to
var magnetized_dir := Vector2.ZERO

var space_state

func _ready():
	for c in get_parent().get_children():
		if c is Movement:
			MovementController = c
			return
	push_error("No movement controller found for PlayerControls")
	
func _physics_process(_delta):
	space_state = get_world_2d().direct_space_state
	
	var moveRight := 0.0
	var moveLeft := 0.0
	var pressRight := 0
	var pressLeft := 0
	
	var jump := false
	
	if !controls_disabled:
		if Global.entity_active and !fade_buffer:
			
			if Input.is_action_just_pressed("game_melee"):
				$SlashBuffer.start()
			if Input.is_action_just_pressed("game_jump"):
				$JumpBuffer.start()
			if Input.is_action_just_pressed("game_ranged"):
				$ProjectileBuffer.start()
				
			# put max speed at 90% of the analog stick
			moveRight = min(Input.get_action_strength("game_right") / max_sens, 1.0)
			moveLeft = min(Input.get_action_strength("game_left") / max_sens, 1.0)
			
			pressRight = 1 if Input.is_action_just_pressed("game_right") else 0
			pressLeft = 1 if Input.is_action_just_pressed("game_left") else 0
			
			MovementController.beginJump = Input.is_action_just_pressed("game_jump") or (!$JumpBuffer.is_stopped() and get_parent().is_on_floor())
			MovementController.holdJump = Input.is_action_pressed("game_jump")
			
			if Stats.game_data[Stats.Data.upgrade_melee] and get_parent().is_on_floor() and (Input.is_action_just_pressed("game_melee") or !$SlashBuffer.is_stopped()):
				var fail = false
				for c in get_parent().get_children():
					if c is Slash:
						fail = true
						break
				if !fail:
					var slash = slash_scene.instance()
					get_parent().add_child(slash)
					var xoff = 10 
					if get_parent().get_node("Movement").facing == Global.HDirs.LEFT:
						xoff = -10
						slash.scale.x = -1
					slash.position = Vector2(xoff, -10)
					slash.scale.y = 1 if last_slash_up else -1
					last_slash_up = !last_slash_up
			
			if Stats.game_data[Stats.Data.upgrade_projectile] and !$ProjectileBuffer.is_stopped() and $ProjectileCooldown.is_stopped():
				var projectile = projectile_scene.instance()
				Global.current_room.add_child(projectile)
				var xoff = 10
				if get_parent().get_node("Movement").facing == Global.HDirs.LEFT:
					xoff = -10
					projectile.scale.x = -1
				projectile.global_position = get_parent().global_position + Vector2(xoff, -10)
				
				get_parent().get_node("EventHandler").freeze_movement()
				MovementController.freeze_gravity = true
				MovementController.knocked_back = true
				MovementController.bypass_max_speed = true
				MovementController._velocity = Vector2(MovementController.Physics.max_run_speed * 1.25 * -projectile.scale.x, 0)
				
				$ProjectileCooldown.start()
				$ProjectileRecoil.start()
				
			var magcoll = space_state.intersect_ray(get_parent().global_position, get_parent().global_position + magnetized_dir * 200, [get_parent().get_node("MagnetTracker")], get_parent().get_node("MagnetTracker").collision_mask)
			if magnetized:
				get_parent().get_node("Electricity").visible = true
				if (!Input.is_action_pressed("game_magnet") or !magcoll):
					magnetized = false
					MovementController.freeze_gravity = false
					MovementController.freeze_decel = false
					MovementController.bypass_max_speed = false
					MovementController.bypass_jump = false
				elif magnetized_dir.y == 0:
					MovementController._velocity.y = 0
			else:
				get_parent().get_node("Electricity").visible = false
				
			if Input.is_action_just_released("game_magnet"):
				magnetized_dir = Vector2.ZERO
				
			if !magnetized and Stats.game_data[Stats.Data.upgrade_magnet] and Input.is_action_pressed("game_magnet"):
				var dir
				if magnetized_dir == Vector2.ZERO:
					dir = Vector2(-1 if MovementController.facing == Global.HDirs.LEFT else 1, 0)
					var mag = 0
					if min(Input.get_action_strength("game_left") / max_sens, 1.0) > mag:
						dir = Vector2(-1, 0)
						mag = min(Input.get_action_strength("game_left") / max_sens, 1.0)
					if min(Input.get_action_strength("game_right") / max_sens, 1.0) > mag:
						dir = Vector2(1, 0)
						mag = min(Input.get_action_strength("game_right") / max_sens, 1.0)
					if min(Input.get_action_strength("game_up") / max_sens, 1.0) > mag:
						dir = Vector2(0, -1)
						mag = min(Input.get_action_strength("game_up") / max_sens, 1.0)
					if min(Input.get_action_strength("game_down") / max_sens, 1.0) > mag:
						dir = Vector2(0, 1)
						mag = min(Input.get_action_strength("game_down") / max_sens, 1.0)
				else:
					dir = magnetized_dir
				
				var coll = space_state.intersect_ray(get_parent().global_position, get_parent().global_position + dir * 200, [get_parent().get_node("MagnetTracker")], get_parent().get_node("MagnetTracker").collision_mask)
				if coll:
					var solidcoll = space_state.intersect_ray(get_parent().global_position, coll["position"]-dir, [get_parent(), coll["collider"]])
					if !solidcoll:
						magnetized = true
						magnetized_to = coll["collider"]
						magnetized_dir = dir
						MovementController.freeze_gravity = true
						MovementController.bypass_max_speed = true
						MovementController._jumping = true
						MovementController._velocity = dir * 200
						if dir.y == -1:
							MovementController.bypass_jump = true
						if dir.x != 0:
							MovementController.freeze_decel = true
				
		if !MovementController.is_input_locked():
			MovementController.move_sign = moveRight - moveLeft

func _on_ProjectileRecoil_timeout():
	get_parent().get_node("EventHandler").unfreeze_movement()
	MovementController.freeze_gravity = false
	MovementController.knocked_back = false
	MovementController.bypass_max_speed = false
