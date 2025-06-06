class_name GridTraveller extends Node2D

@export var grid: Grid2D = null
@export var speed: int = 50

@onready var tile: Vector2i = Vector2i.ZERO if grid == null else grid.get_tile_from_coords(global_position)

var coords_move_to: Variant = null
var tile_direction: Vector2i = Vector2i.ZERO:
	set(td):
		if td != Vector2i.ZERO and td != Vector2i.UP and td != Vector2i.DOWN and td != Vector2i.LEFT and td != Vector2i.RIGHT:
			return
		if !is_tile_walkable(tile + td):
			return
		tile_direction = td
		on_tile_direction_changed()
var tile_direction_next: Vector2i = Vector2.ZERO
var next_tile: Variant = null

func _process(_delta: float) -> void:
	if coords_move_to is Vector2i:
		if global_position == Vector2(coords_move_to):
			coords_move_to = null
			tile_direction = tile_direction_next
		tile = grid.get_tile_from_coords(global_position)

func on_tile_direction_changed() -> void:
	if grid == null or tile_direction == Vector2i.ZERO:
		return
	
	coords_move_to = grid.get_coords_from_tile(tile + tile_direction)
	tile_direction_next = calculate_tile_direction_next()

func calculate_tile_direction_next() -> Vector2i:
	if grid == null or tile_direction == Vector2i.ZERO:
		return Vector2i.ZERO
	
	var direction: Vector2i = tile_direction
	return direction if is_tile_walkable(tile + direction) else Vector2i.ZERO

func is_tile_walkable(t: Vector2i) -> bool:
	var tile_data: TileData = grid.get_tiledata_from_tile(t)
	if tile_data != null and tile_data.has_custom_data('type'):
		match tile_data.get_custom_data('type'):
			'wall':
				return false
	return true
