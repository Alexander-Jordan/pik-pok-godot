class_name Ghost extends GridTraveller

#region ENUMS
enum HouseState {
	NONE,
	GOING_IN,
	GOING_OUT,
	WAITING,
}
#endregion

#region CONSTANTS
const DIRECTION_MAP: Dictionary[String, Vector2i] = {
	'up': Vector2i.UP,
	'left': Vector2i.LEFT,
	'down': Vector2i.DOWN,
	'right': Vector2i.RIGHT,
}
#endregion

#region VARIABLES
@export var house_center_point: Vector2 = Vector2(112, 140)
@export var house_entrance_point: Vector2 = Vector2(112, 116)
@export var house_state_reset: HouseState = HouseState.NONE:
	set(hsr):
		if !HouseState.values().has(hsr) or hsr == house_state_reset:
			return
		house_state_reset = hsr
@export var house_waiting_point: Vector2 = Vector2(112, 140)
@export var pacman: Pacman
@export var tile_target_scatter: Vector2i = Vector2i.ZERO

@onready var animatedsprite_2d_body: AnimatedSprite2D = $animatedsprite2d_body
@onready var animatedsprite_2d_eyes: AnimatedSprite2D = $animatedsprite2d_eyes
@onready var spawn_point: Vector2 = global_position
@onready var timer: Timer = $Timer

var house_state: HouseState = house_state_reset:
	set(hs):
		if !HouseState.values().has(hs) or hs == house_state:
			return
		house_state = hs
		match hs:
			HouseState.WAITING:
				if timer:
					timer.start()
var house_target_point: Vector2 = Vector2.ZERO:
	set(htp):
		house_target_point = htp
		tile_direction = global_position.direction_to(htp).round()
		match house_state:
			HouseState.GOING_IN:
				if global_position == house_waiting_point:
					house_state = HouseState.WAITING
					eaten = false
			HouseState.GOING_OUT:
				if htp == Vector2.ZERO:
					tile_direction = DIRECTION_MAP['left']
					house_state = HouseState.NONE
var eaten: bool = false:
	set(e):
		if e == eaten:
			return
		eaten = e
		animatedsprite_2d_body.visible = !e
var mode: GM.GhostMode = GM.ghost_mode:
	set(m):
		if !GM.GhostMode.values().has(m) or m == mode:
			return
		if mode != GM.GhostMode.FRIGHTENED:
			tile_direction = -tile_direction
		mode = m
var tile_target: Vector2i = Vector2i.ZERO:
	set(tt):
		if tt == tile_target:
			return
		tile_target = tt
#endregion

#region FUNCTIONS
func _process(delta: float) -> void:
	if GM.mode != GM.Mode.PLAYING:
		return
	
	super(delta)
	
	if house_state != HouseState.NONE:
		if house_target_point == Vector2.ZERO:
			house_target_point = get_next_house_target_point()
		global_position = global_position.move_toward(house_target_point, delta * speed)
		if global_position == house_target_point:
			house_target_point = get_next_house_target_point()
		return
	
	if global_position != coords_move_to:
		global_position = global_position.move_toward(coords_move_to, delta * speed)
		if eaten:
			if tile == grid.get_tile_from_coords(house_entrance_point):
				house_state = HouseState.GOING_IN

func _ready() -> void:
	GM.mode_changed.connect(on_game_mode_changed)
	GM.reset.connect(reset)
	tile_direction_changed.connect(on_tile_direction_changed)
	timer.timeout.connect(on_timer_timeout)
	
	coords_move_to = grid.get_coords_from_tile(tile + tile_direction)
	house_state = house_state_reset
	on_tile_direction_changed(tile_direction)

func calculate_tile_direction_next() -> Vector2i:
	mode = GM.ghost_mode
	if mode == GM.GhostMode.SCATTER:
		tile_target = tile_target_scatter
	if mode == GM.GhostMode.CHASE:
		tile_target = get_tile_target_during_chase()
	if eaten:
		tile_target = grid.get_tile_from_coords(house_entrance_point)
	return get_tile_direction_next_from_tile_target()

func get_next_house_target_point() -> Vector2:
	match house_state:
		HouseState.GOING_IN:
			if house_target_point == Vector2.ZERO:
				return house_entrance_point
			elif house_target_point == house_entrance_point:
				return house_center_point
			elif house_target_point == house_center_point:
				return house_waiting_point
		HouseState.GOING_OUT:
			if ![house_center_point, house_entrance_point].has(house_target_point):
				return house_center_point
			elif house_target_point == house_center_point:
				return house_entrance_point
			elif house_target_point == house_entrance_point:
				return Vector2.ZERO
		HouseState.WAITING:
			var above: Vector2 = Vector2(house_waiting_point.x, house_waiting_point.y - 4)
			var below: Vector2 = Vector2(house_waiting_point.x, house_waiting_point.y + 4)
			return above if house_target_point != above else below
	return Vector2.ZERO

func get_tile_direction_next_from_tile_target() -> Vector2i:
	if grid == null:
		return Vector2i.ZERO
	var next_tile_direction: Vector2i = Vector2i.ZERO
	for direction: Vector2i in DIRECTION_MAP.values():
		# ignore the direction from which the ghost came from
		if direction == -tile_direction:
			continue
		# ignore if the tile direction is not walkable
		if !is_tile_walkable(tile + direction):
			continue
		# if no next direction has been set yet: set it
		if next_tile_direction == Vector2i.ZERO:
			next_tile_direction = direction
			continue
		# override the next tile direction with this one only if it is closer
		if (tile + direction).distance_to(tile_target) < (tile + next_tile_direction).distance_to(tile_target):
			next_tile_direction = direction
	# if no next tile direction was set: walk back as last resort
	return next_tile_direction if next_tile_direction != Vector2i.ZERO else -tile_direction

func get_tile_target_during_chase() -> Vector2i:
	return tile_target_scatter

func on_game_mode_changed(m: GM.Mode) -> void:
	match m:
		GM.Mode.PLAYING:
			start()

func on_tile_direction_changed(td: Vector2i) -> void:
	if DIRECTION_MAP.values().has(td):
		animatedsprite_2d_eyes.play(DIRECTION_MAP.find_key(td))

func on_timer_timeout() -> void:
	if house_state == HouseState.WAITING:
		house_state = HouseState.GOING_OUT

func start() -> void:
	if house_state == HouseState.WAITING:
		timer.start()

func reset() -> void:
	global_position = spawn_point
	house_state = house_state_reset
	tile = grid.get_tile_from_coords(global_position)
	tile_direction = tile_direction_reset
#endregion
