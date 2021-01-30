class_name PlayerControls
extends Node2D

export(float) var max_sens := 0.9
var MovementController

var fade_buffer := true
var controls_disabled := false

var slash_scene = preload("res://src/entities/player/slash.tscn")
var projectile_scene = preload("res://src/entities/player/projectile.tscn")
var last_slash_up := false

func _ready():
	for c in get_parent().get_children():
		if c is Movement:
			MovementController = c
			return
	push_error("No movement controller found for PlayerControls")
	
func _physics_process(_delta):
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
				
		if !MovementController.is_input_locked():
			MovementController.move_sign = moveRight - moveLeft

func _on_ProjectileRecoil_timeout():
	get_parent().get_node("EventHandler").unfreeze_movement()
	MovementController.freeze_gravity = false
	MovementController.knocked_back = false
	MovementController.bypass_max_speed = false
