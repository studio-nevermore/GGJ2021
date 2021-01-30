class_name PhysicsAttributes
extends Resource

export(float) var FLOOR_MAX_ANGLE = 46 setget ,get_floor_max_angle
export(float) var FLOOR_FULL_SPEED_ANGLE = 46 setget, get_floor_full_speed_angle

export(float) var jump_height = 4 setget set_jump_height,get_jump_height
export(float) var jump_length = 5 setget set_jump_length,get_jump_length

export(float) var accel_run = 36 setget ,get_accel_run
export(float) var decel_run = 120 setget ,get_decel_run
export(float) var accel_air = 90 setget ,get_accel_air
export(float) var decel_air = 60 setget ,get_decel_air

export(float) var accel_gravity = 120 setget ,get_accel_gravity
export(float) var accel_jump = 60 setget ,get_accel_jump

export(float) var max_run_speed = 12 setget ,get_max_run_speed
# export(float) var terminal_vel = 12

export(float) var COYOTE_TIME = 0.05
export(float) var DROPTHROUGH_TIME = 0.3

var jump_vel: Vector2 = calculate_jump_vel()

func calculate_jump_vel() -> Vector2:
	# access self.var to use the getters
	return Vector2(2*(self.jump_length+Global.TILE_SIZE)-1, -sqrt(2*self.accel_jump*self.jump_height))

func get_floor_max_angle() -> float:
	return deg2rad(FLOOR_MAX_ANGLE)

func get_floor_full_speed_angle() -> float:
	return deg2rad(FLOOR_FULL_SPEED_ANGLE)

func set_jump_height(j: float) -> void:
	jump_height = j
	jump_vel = calculate_jump_vel()

func get_jump_height() -> float:
	return jump_height * Global.TILE_SIZE

func set_jump_length(j: float) -> void:
	jump_length = j
	jump_vel = calculate_jump_vel()

func get_jump_length() -> float:
	return jump_length * Global.TILE_SIZE

func get_accel_run() -> float:
	return accel_run * Global.TILE_SIZE

func get_decel_run() -> float:
	return decel_run * Global.TILE_SIZE

func get_accel_air() -> float:
	return accel_air * Global.TILE_SIZE

func get_decel_air() -> float:
	return decel_air * Global.TILE_SIZE

func get_accel_gravity() -> float:
	return accel_gravity * Global.TILE_SIZE

func get_accel_jump() -> float:
	return accel_jump * Global.TILE_SIZE

func get_max_run_speed() -> float:
	return max_run_speed * Global.TILE_SIZE
