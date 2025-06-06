class_name PacdotSpawner extends Spawner2D

var spawn_point_cells: Array[Vector2i] = []
var tile_map_layer: TileMapLayer = null

func _ready() -> void:
	GM.reset.connect(reset)
	
	tile_map_layer = get_tile_map_layer()
	spawn_point_cells = tile_map_layer.get_used_cells()
	tile_map_layer.clear()
	reset()

func get_tile_map_layer() -> TileMapLayer:
	for child in get_children():
		if child is not TileMapLayer:
			continue
		return child
	assert(false, 'Missing a TileMapLayer node as a child to the PacdotSpawner.')
	return null

func reset() -> void:
	despawn_all()
	for cell in spawn_point_cells:
		spawn(tile_map_layer.map_to_local(cell))
