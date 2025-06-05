class_name Pacman extends GridTraveller

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	super(delta)
	if coords_move_to is Vector2i:
		global_position = global_position.move_toward(coords_move_to, delta*speed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('up'):
		tile_direction = Vector2i.UP
	if event.is_action_pressed('down'):
		tile_direction = Vector2i.DOWN
	if event.is_action_pressed('left'):
		tile_direction = Vector2i.LEFT
	if event.is_action_pressed('right'):
		tile_direction = Vector2i.RIGHT
