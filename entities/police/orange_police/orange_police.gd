class_name OrangePolice extends Police

## 8 tiles away (8 pixels x 8 tiles)
const DISTANCE_FROM_PIKPOK: float = 64

func get_tile_target_during_chase() -> Vector2i:
	if global_position.distance_to(pikpok.global_position) < DISTANCE_FROM_PIKPOK:
		return tile_target_scatter
	return pikpok.tile
