class_name Entity
extends KinematicBody2D

export(int) var depth_override = null
export(int) var depth_offset := 0
export(int) var bottom_offset = 0

var near_player := false

export(Stats.Flags) var disappear_flag = 0
export(Stats.Flags) var appear_flag = 0
export(Stats.Flags) var set_flag_on_death = 0

func _ready():
	add_to_group("entity")
	if disappear_flag > 0 and Stats.get_flag(disappear_flag) > 0:
		queue_free()
	elif appear_flag > 0 and Stats.get_flag(appear_flag) == 0:
		queue_free()

func _process(delta):
	set_depth()
	
func find_player_distance() -> void:
	var p = Global.get_player()
	if p and p.position.distance_to(position) < 100:
		near_player = true
	
func set_depth() -> void:
	pass
	#if depth_override != null:
	#	z_index = depth_override
	#else:
	#	var view = get_viewport()
	#	var bottom = global_position.y + bottom_offset
	#	z_index = 100 + ((bottom + view.canvas_transform.origin.y) / max(view.size.y, 1)) * 300 + depth_offset

func _can_drop_through_platform() -> bool:
	return false

func queue_free():
	if set_flag_on_death > 0:
		Stats.set_flag(set_flag_on_death)
	.queue_free()
