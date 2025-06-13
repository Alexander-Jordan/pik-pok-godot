class_name Ghost extends GridTraveller

@export var tile_target_scatter: Vector2i = Vector2i.ZERO

@onready var animatedsprite_2d_body: AnimatedSprite2D = $animatedsprite2d_body
@onready var animatedsprite_2d_eyes: AnimatedSprite2D = $animatedsprite2d_eyes
@onready var spawn_point: Vector2 = global_position

var direction_map: Dictionary[String, Vector2i] = {
	'up': Vector2i.UP,
	'left': Vector2i.LEFT,
	'down': Vector2i.DOWN,
	'right': Vector2i.RIGHT,
}
var mode: GM.GhostMode = GM.ghost_mode:
	set(m):
		if !GM.GhostMode.values().has(m) or m == mode:
			return
		if mode != GM.GhostMode.FRIGHTENED:
			tile_direction = -tile_direction
		mode = m
var tile_target: Vector2i = Vector2i.ZERO

func _process(delta: float) -> void:
	if GM.mode != GM.Mode.PLAYING:
		return
	
	super(delta)
	if global_position != Vector2(coords_move_to):
		global_position = global_position.move_toward(coords_move_to,delta * speed)

func _ready() -> void:
	GM.mode_changed.connect(on_game_mode_changed)
	GM.reset.connect(reset)
	tile_direction_changed.connect(on_tile_direction_changed)
	
	coords_move_to = grid.get_coords_from_tile(tile + tile_direction)

func _unhandled_input(event: InputEvent) -> void:
	for direction in direction_map:
		if event.is_action_pressed(direction):
			tile_direction = direction_map[direction]

func calculate_tile_direction_next() -> Vector2i:
	mode = GM.ghost_mode
	if mode == GM.GhostMode.SCATTER:
		tile_target = tile_target_scatter
	return get_tile_direction_next_from_tile_target()

func get_tile_direction_next_from_tile_target() -> Vector2i:
	if grid == null:
		return Vector2i.ZERO
	
	var next_tile_direction: Vector2i = Vector2i.ZERO
	for direction: Vector2i in direction_map.values():
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

func on_game_mode_changed(m: GM.Mode) -> void:
	match m:
		GM.Mode.PLAYING:
			start()

func on_tile_direction_changed(td: Vector2i) -> void:
	if direction_map.values().has(td):
		animatedsprite_2d_eyes.play(direction_map.find_key(td))

func reset() -> void:
	global_position = spawn_point
	tile = grid.get_tile_from_coords(global_position)
	tile_direction = Vector2i.ZERO

func start() -> void:
	if tile_direction == Vector2i.ZERO:
		tile_direction = Vector2i.RIGHT
