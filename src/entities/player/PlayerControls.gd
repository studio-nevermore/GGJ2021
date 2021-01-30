class_name PlayerControls
extends Node2D

export(float) var max_sens := 0.9
var MovementController

var fade_buffer := true
var controls_disabled := false

var slash_scene = preload("res://src/entities/player/slash.tscn")
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
				
			# put max speed at 90% of the analog stick
			moveRight = min(Input.get_action_strength("game_right") / max_sens, 1.0)
			moveLeft = min(Input.get_action_strength("game_left") / max_sens, 1.0)
			
			pressRight = 1 if Input.is_action_just_pressed("game_right") else 0
			pressLeft = 1 if Input.is_action_just_pressed("game_left") else 0
			
			MovementController.beginJump = Input.is_action_just_pressed("game_jump") or (!$JumpBuffer.is_stopped() and get_parent().is_on_floor())
			MovementController.holdJump = Input.is_action_pressed("game_jump")
			if Stats.game_data[Stats.Data.upgrade_melee] and (Input.is_action_just_pressed("game_melee") or !$SlashBuffer.is_stopped()):
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
				
		if !MovementController.is_input_locked():
			MovementController.move_sign = moveRight - moveLeft
