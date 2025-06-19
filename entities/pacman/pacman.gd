class_name Pacman extends GridTraveller

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collector_2d: Collector2D = $Collector2D
@onready var spawn_point: Vector2 = global_position

var input_direction_map: Dictionary[String, Vector2i] = {
	'up': Vector2i.UP,
	'left': Vector2i.LEFT,
	'down': Vector2i.DOWN,
	'right': Vector2i.RIGHT,
}
var look_direction: Vector2i = Vector2.ZERO:
	set(ld):
		if ![Vector2i.ZERO, Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].has(ld):
			return
		look_direction = ld
		if ld == Vector2i.ZERO:
			animated_sprite_2d.animation = 'default'
			animated_sprite_2d.stop()
		else:
			animated_sprite_2d.look_at(position + Vector2(ld))
			if !animated_sprite_2d.is_playing() or animated_sprite_2d.animation != 'default':
				animated_sprite_2d.play('default')
var skip_next_frame: bool = false
func _process(delta: float) -> void:
	if GM.mode != GM.Mode.PLAYING:
		return
	if skip_next_frame:
		skip_next_frame = false
		return
	
	super(delta)
	get_input()
	if global_position != coords_move_to:
		global_position = global_position.move_toward(coords_move_to, delta * speed)

func _ready() -> void:
	collector_2d.collected.connect(on_collected)
	GM.mode_changed.connect(on_game_mode_changed)
	GM.reset.connect(reset)

func get_input() -> void:
	for direction in input_direction_map:
		if Input.is_action_pressed(direction):
			tile_direction = input_direction_map[direction]
			look_direction = tile_direction

func get_speed() -> float:
	match GM.level:
		1:
			return speed * 0.8
		5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20:
			return speed
		_:
			return speed * 0.9

func on_collected(collectable: Collectable2D) -> void:
	match collectable.identifier:
		'pacdot', 'power_pellet':
			# skip 1 frame everytime a pacdot is collected
			skip_next_frame = true

func on_game_mode_changed(mode: GM.Mode) -> void:
	match mode:
		GM.Mode.PLAYING:
			start()

func reset() -> void:
	look_direction = Vector2i.ZERO
	global_position = spawn_point
	tile = grid.get_tile_from_coords(global_position)
	tile_direction = tile_direction_reset

func start() -> void:
	look_direction = tile_direction
