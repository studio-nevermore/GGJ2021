class_name Parallax
extends Sprite

export(bool) var looping_horizontal = false
export(bool) var looping_vertical = false
export(float) var parallax_layer = 0
export(Vector2) var horizontal_range = Vector2(0, 0)
export(Vector2) var vertical_range = Vector2(0, 0)

onready var start_pos := global_position

func _ready():
	var start_rect = region_rect
	if looping_horizontal:
		region_rect.end.x = 20000
	if looping_vertical:
		region_rect.end.y = 20000

func _physics_process(delta):
	var ctrans = get_viewport().canvas_transform
	var view_pos = -ctrans.origin
	var view_end = view_pos + Global.VIEW_SIZE
	var view_middle = view_pos + (view_end - view_pos) / 2
	var pos_diff = start_pos - Vector2(view_pos.x, view_end.y - 250)
	
	var spd = parallax_layer
	if parallax_layer > 0:
		spd = 1 * ((abs(parallax_layer)) * 0.1)
	else:
		spd = 1 * ((abs(parallax_layer)) * 0.25)
	spd = abs(spd)
	
	var inc = pos_diff * -sign(parallax_layer) * spd
	global_position = start_pos + Vector2(inc.x, inc.y / 4)
	
	if !looping_horizontal:
		global_position.x = clamp(global_position.x, start_pos.x + horizontal_range.x, start_pos.x + horizontal_range.y)
	else:
		pass#global_position.x = max(global_position.x, 0)
	if !looping_vertical:
		global_position.y = clamp(global_position.y, start_pos.y + vertical_range.x, start_pos.y + vertical_range.y)
	else:
		global_position.y = min(global_position.y, 0)
	
	if parallax_layer < 0:
		z_index = 100 + -parallax_layer
	else:
		z_index = -1 - parallax_layer
