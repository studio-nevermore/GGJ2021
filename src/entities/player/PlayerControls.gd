class_name PlayerControls
extends Node2D

export(float) var max_sens := 0.9
var MovementController

var fade_buffer := true
var controls_disabled := false

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
			# put max speed at 90% of the analog stick
			moveRight = min(Input.get_action_strength("game_right") / max_sens, 1.0)
			moveLeft = min(Input.get_action_strength("game_left") / max_sens, 1.0)
			
			pressRight = 1 if Input.is_action_just_pressed("game_right") else 0
			pressLeft = 1 if Input.is_action_just_pressed("game_left") else 0
			
			MovementController.beginJump = Input.is_action_just_pressed("game_jump")
			MovementController.holdJump = Input.is_action_pressed("game_jump")
				
		if !MovementController.is_input_locked():
			MovementController.move_sign = moveRight - moveLeft
