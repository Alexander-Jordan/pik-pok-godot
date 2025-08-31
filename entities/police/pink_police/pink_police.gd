class_name PinkPolice extends Police

const TILES_AHEAD_OF_PIKPOK: int = 4

func get_tile_target_during_chase() -> Vector2i:
	return pikpok.tile + (pikpok.look_direction * TILES_AHEAD_OF_PIKPOK)
