extends Node2D

const TILE_SIZE = 8
const ONE_FRAME = 1.0/60.0
const VIEW_SIZE = Vector2(240, 135)

var current_pausestate = PauseState.NORMAL
var old_pausestate = PauseState.NORMAL
var entity_active = true

var current_room
var current_room_control
var current_room_path := "misc/title"
var current_boundary_entrance := -1

var final_cutscene := false

var stage_music_level := 0

var start_from_save := true

var gui

# flag values stolen shamelessly from BYOND
enum Dirs {
	UP = 1,
	DOWN = 2,
	RIGHT = 4,
	LEFT = 8,
}
enum Diags {
	UP_RIGHT = Dirs.UP|Dirs.RIGHT,
	UP_LEFT = Dirs.UP|Dirs.LEFT,
	DOWN_RIGHT = Dirs.DOWN|Dirs.RIGHT,
	DOWN_LEFT = Dirs.DOWN|Dirs.LEFT,
}

# used for iteration, exports, etc
enum AllDirs {
	UP = Dirs.UP,
	DOWN = Dirs.DOWN,
	RIGHT = Dirs.RIGHT,
	LEFT = Dirs.LEFT,
	UP_RIGHT = Diags.UP_RIGHT,
	UP_LEFT = Diags.UP_LEFT,
	DOWN_RIGHT = Diags.DOWN_RIGHT,
	DOWN_LEFT = Diags.DOWN_LEFT,
}
enum HDirs {
	RIGHT = Dirs.RIGHT,
	LEFT = Dirs.LEFT,
}
enum VDirs {
	UP = Dirs.UP,
	DOWN = Dirs.DOWN,
}

enum PauseState {
	NORMAL,
	PAUSED,
	EVENT,
	HITLAG
}

# for collision layer/mask setting/getting functions
enum CollisionLayers {
	COLLISION,
	WATER,
	PINFLUENCE,
	DAMAGE_TO_ENEMY,
	DAMAGE_TO_PLAYER,
	ENVIRONMENT
}

# for direct manipulation of collision layers/masks
enum CollisionBits {
	COLLISION = 1 << CollisionLayers.COLLISION,
	WATER = 1 << CollisionLayers.WATER,
	PINFLUENCE = 1 << CollisionLayers.PINFLUENCE,
	DAMAGE_TO_ENEMY = 1 << CollisionLayers.DAMAGE_TO_ENEMY,
	DAMAGE_TO_PLAYER = 1 << CollisionLayers.DAMAGE_TO_PLAYER
	ENVIRONMENT = 1 << CollisionLayers.ENVIRONMENT
}

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
			
func vec_scale_x_to(v: Vector2, x: float) -> Vector2:
	v = v.normalized()
	v /= v.x
	return v * x

func vec_scale_y_to(v: Vector2, y: float) -> Vector2:
	v = v.normalized()
	v /= v.y
	return v * y

func scale_range_to(x: float, y_min: float, y_max: float) -> float:
    return y_min*(1-x) + y_max*x

func rad2vector(angle) -> Vector2:
	return polar2cartesian(1, angle)

func deg2vector(angle) -> Vector2:
	return rad2vector(deg2rad(angle))
			
func approach_value(current: float, target: float, increase: float) -> float:
	if target != current:
		if target < current:
			increase *= -1
		current += increase
		if abs(target - current) < abs(increase):
			current = target
		
	return current
	
func approach_vector(current: Vector2, target: Vector2, increase: float) -> Vector2:
	if target != current:
		current -= rad2vector(current.angle_to_point(target)) * increase
		if current.distance_to(target) < increase:
			current = target
		
	return current
		
func shift_index(current, minval, maxval, inc):
	current += inc
	
	if current > maxval:
		current = minval + (current - 1) - maxval
	if current < minval:
		current = maxval - minval - abs((current - 1))
		
	return current
	
func clamp_degrees(deg) -> float:
	return fposmod(deg, 360)
	
func get_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
	
func get_camera():
	var cams = get_tree().get_nodes_in_group("camera")
	var cam = null
	for c in cams:
		if c.focus:
			cam = c
			break
	return cam

func set_pause_state(ps = PauseState.NORMAL):
	if current_pausestate != ps:
		old_pausestate = current_pausestate
	current_pausestate = ps
	var tree = get_tree()
	
	tree.set_group_flags(2, "player", "pause_mode", Node.PAUSE_MODE_INHERIT)
	tree.set_group_flags(2, "view", "pause_mode", Node.PAUSE_MODE_INHERIT)
	tree.set_group_flags(2, "entity", "pause_mode", Node.PAUSE_MODE_INHERIT)
	tree.set_group_flags(2, "tile", "pause_mode", Node.PAUSE_MODE_INHERIT)
	
	match ps:
		PauseState.NORMAL:
			pause_tiles(false)
			tree.paused = false
			entity_active = true
		PauseState.PAUSED:
			pause_tiles(true)
			tree.set_group_flags(2, "views", "pause_mode", Node.PAUSE_MODE_STOP)
			tree.paused = true
			entity_active = false
		PauseState.EVENT:
			pause_tiles(false)
			tree.set_group_flags(2, "view", "pause_mode", Node.PAUSE_MODE_PROCESS)
			tree.set_group_flags(2, "player", "pause_mode", Node.PAUSE_MODE_PROCESS)
			tree.set_group_flags(2, "entity", "pause_mode", Node.PAUSE_MODE_PROCESS)
			tree.set_group_flags(2, "tile", "pause_mode", Node.PAUSE_MODE_PROCESS)
			var p = get_player()
			#if p:
			#	p.get_node("Movement").move_sign = 0
			tree.paused = true
			entity_active = false
		PauseState.HITLAG:
			tree.set_group_flags(2, "view", "pause_mode", Node.PAUSE_MODE_STOP)
			tree.paused = true
			entity_active = false

func pause_tiles(pause := true) -> void:
	for tm in get_tree().get_nodes_in_group("atilemap"):
		if tm is TileMap:
			var ts = tm.tile_set
			for t in ts.get_tiles_ids():
				var tinfo = ts.tile_get_texture(t)
				if tinfo is AnimatedTexture:
					tinfo.pause = pause
					ts.tile_set_texture(t, tinfo)
