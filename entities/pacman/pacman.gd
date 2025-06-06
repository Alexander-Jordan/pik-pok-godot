class_name Pacman extends GridTraveller

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var input_direction_map: Dictionary[String, Vector2i] = {
	'up': Vector2i.UP,
	'left': Vector2i.LEFT,
	'down': Vector2i.DOWN,
	'right': Vector2i.RIGHT,
}

func _process(delta: float) -> void:
	super(delta)
	if coords_move_to is Vector2i:
		global_position = global_position.move_toward(coords_move_to, delta*speed)

func _ready() -> void:
	GM.mode_changed.connect(on_game_mode_changed)

func _unhandled_input(event: InputEvent) -> void:
	if GM.mode != GM.Mode.PLAYING:
		return
	
	for direction in input_direction_map:
		if event.is_action_pressed(direction):
			tile_direction = input_direction_map[direction]
	animated_sprite_2d.look_at(position + Vector2(tile_direction))

func on_game_mode_changed(mode: GM.Mode) -> void:
	match mode:
		GM.Mode.PLAYING:
			start()

func start() -> void:
	if tile_direction == Vector2i.ZERO:
		tile_direction = Vector2i.RIGHT
	animated_sprite_2d.play('default')
