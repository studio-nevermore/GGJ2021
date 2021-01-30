class_name PCamera
extends Node2D


# Declare member variables here. Examples:
export(bool) var focus := false

var current_pos := Vector2.ZERO
var target_pos := Vector2.ZERO
var offset_pos := Vector2.ZERO
var final_offset := Vector2.ZERO

var final_offset_destination := Vector2.ZERO

var special_offset := Vector2.ZERO
var pos_override := Vector2.ZERO

var boundary := Rect2(Vector2.ZERO, Vector2.ZERO)
var boundary_area: Area2D = null
var boundary_shape: CollisionShape2D = null

var fade_rect: ColorRect

# Shake params
# Multiplier for maximum shake distance
var shake_intensity = 0
# Current shake offset
var shake_pos = Vector2.ZERO

# Saves whether fading in or out
var fadeout := false

var frozen := false

var ignore_player_grounded := true

signal fade_finished(fadeout)

func _ready():
	for r in get_tree().get_nodes_in_group("faderect"):
		r.connect("fade_finished", self, "_on_Fade_Finished")
		fade_rect = r
		
	camera_snap()
	
	ignore_player_grounded = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Camera shake
	if shake_intensity > 0:
		shake_pos = Vector2((randf() * 10.0 - 5.0) * shake_intensity, (randf() * 10.0 - 5.0) * shake_intensity)
	else:
		shake_pos = Vector2.ZERO
	
	if focus:
		# Move camera
		# Get viewport
		if !frozen:
			var view = get_viewport()
			
			find_position()
			find_next_position()
			
			camera_finalize()
			
		# Position rects
		#$FadeoutRect.rect_position = current_pos - get_parent().position
		#$FadeoutRect.rect_size = view.size

func camera_fade(speed: float = 1.0, f: bool = false) -> void:
	if fade_rect:
		fade_rect.fade(speed, f)
	
func camera_shake(time: float = 10, intensity: float = 1) -> void:
	#$ShakeTimer.start(float(time)/60)
	$ShakeTimer.start(time)
	shake_intensity = intensity

func camera_snap() -> void:
	find_position()
	current_pos = target_pos + offset_pos
	camera_finalize()

func find_position() -> void:
	var view = get_viewport()
	boundary = Rect2(Vector2(0, 0), Vector2(5000, 5000))
	if boundary_area != null:
		boundary.position.x = max(boundary.position.x, boundary_area.global_position.x + (boundary_shape.position.x - boundary_shape.shape.extents.x) * boundary_area.scale.x)
		boundary.position.y = max(boundary.position.y, boundary_area.global_position.y + (boundary_shape.position.y - boundary_shape.shape.extents.y) * boundary_area.scale.y)
		boundary.end.x = min(boundary.end.x, boundary_area.global_position.x + (boundary_shape.position.x + boundary_shape.shape.extents.x) * boundary_area.scale.x)
		boundary.end.y = min(boundary.end.y, boundary_area.global_position.y + (boundary_shape.position.y + boundary_shape.shape.extents.y) * boundary_area.scale.y)
		boundary.end -= view.size
		if boundary.end.x < boundary.position.x:
			boundary.end.x = boundary.position.x
		if boundary.end.y < boundary.position.y:
			boundary.end.y = boundary.position.y
			
	final_offset_destination = Vector2.ZERO
	
	# Move to target position
	var ppos = get_parent().global_position
	var temp_pos = ppos - Global.VIEW_SIZE / 2 - Vector2(0, Global.VIEW_SIZE.y * 0.25) + special_offset
	var dir = -1
	if get_parent().get_node("Movement").facing == Global.HDirs.RIGHT:
		dir = 1
	temp_pos.x += Global.VIEW_SIZE.x * 0.15 * dir
	
	if !ignore_player_grounded and !get_parent().is_on_floor():
		if ppos.y < get_parent().jump_takeoff_position.y:
			temp_pos.y = current_pos.y
			if ppos.y < current_pos.y + Global.VIEW_SIZE.y * 0.25:
				temp_pos.y -= current_pos.y + Global.VIEW_SIZE.y * 0.25 - ppos.y
		elif get_parent().jump_takeoff_position.y != 0 and ppos.y > get_parent().jump_takeoff_position.y + 50:
			final_offset_destination = Vector2(0, 50)
	else:
		current_pos += final_offset
		final_offset = Vector2.ZERO
		
	target_pos = temp_pos
	if get_parent().dying:
		target_pos.y = max(target_pos.y, current_pos.y)
	
	target_pos.x = floor(target_pos.x)
	target_pos.y = floor(target_pos.y)
	target_pos.x = clamp(target_pos.x, boundary.position.x, boundary.end.x)
	target_pos.y = clamp(target_pos.y, boundary.position.y, boundary.end.y)
	
	if pos_override != Vector2.ZERO:
		target_pos = pos_override
	
	if current_pos == Vector2.ZERO:
		current_pos = -view.canvas_transform.origin

func find_next_position() -> void:
	var distance = target_pos - current_pos
	var spd = 0.08
	var next_pos = current_pos + distance * spd
	next_pos.x = round(next_pos.x)
	next_pos.y = round(next_pos.y)
	
	if abs(target_pos.x - next_pos.x) < distance.x * spd && abs(target_pos.y - next_pos.y) < distance.y * spd:
		next_pos = target_pos
	
	offset_pos = next_pos - target_pos
	
	# Anchor within boundaries
	# next_pos.x = clamp(next_pos.x, boundary.position.x, boundary.end.x)
	# next_pos.y = clamp(next_pos.y, boundary.position.y, boundary.end.y)
	
	current_pos = next_pos
	
	var offset_distance = final_offset_destination - final_offset
	var offset_spd = 0.08
	var next_offset = final_offset + offset_distance * offset_spd
	next_offset.x = round(next_offset.x)
	next_offset.y = round(next_offset.y)
	if abs(final_offset_destination.x - next_offset.x) < offset_distance.x * offset_spd && abs(final_offset_destination.y - next_offset.y) < offset_distance.y * offset_spd:
		next_offset = final_offset_destination
	final_offset = next_offset

func camera_finalize() -> void:
	if Global.current_room_control.uses_camera:
		var final_pos = current_pos + final_offset
		final_pos.x = clamp(final_pos.x, boundary.position.x, boundary.end.x)
		final_pos.y = clamp(final_pos.y, boundary.position.y, boundary.end.y)
		
		get_viewport().canvas_transform.origin = -(final_pos + shake_pos)
	else:
		get_viewport().canvas_transform.origin = Vector2.ZERO
		current_pos = Vector2.ZERO

func set_focus(f: bool) -> void:
	if f == true:
		get_tree().set_group_flags(2, "cameras", "focus", false)
	focus = f
	
func set_boundary(area: Area2D, setting: bool = true) -> void:
	var shape: CollisionShape2D = area.get_node("CollisionShape2D")
	if shape:
		if focus:
			if setting:
				boundary_area = area
				boundary_shape = shape
			elif boundary_area == area:
				boundary_area = null
				boundary_shape = null

func _on_ShakeTimer_timeout():
	shake_intensity = 0

func _on_FadePlayer_animation_finished(anim_name):
	emit_signal("fade_finished", fadeout)
	
func _on_Fade_Finished(out):
	emit_signal("fade_finished", out)
