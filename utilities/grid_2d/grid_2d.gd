class_name Grid2D extends Node2D

@export var tile_size: int = 8
@export var tiles_x: int = 28
@export var tiles_y: int = 36

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func get_coords_from_tile(tile: Vector2i) -> Vector2i:
	var tile_center: int = int(tile_size / 2.0)
	return Vector2i(tile.x * tile_size + tile_center, tile.y * tile_size + tile_center - 1)
	
func get_tile_from_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(floori(coords.x / float(tile_size)), floori(coords.y / float(tile_size)))

func get_tiledata_from_tile(tile: Vector2i) -> TileData:
	return tile_map_layer.get_cell_tile_data(tile_map_layer.local_to_map(get_coords_from_tile(tile)))
