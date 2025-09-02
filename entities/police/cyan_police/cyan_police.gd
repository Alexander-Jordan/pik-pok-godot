class_name CyanPolice extends Police

const TILES_AHEAD_OF_PIKPOK: int = 2

@export var red_police: RedPolice

func get_tile_target_during_chase() -> Vector2i:
	var pikpok_tile_offset: Vector2i = pikpok.tile + (pikpok.look_direction * TILES_AHEAD_OF_PIKPOK)
	return pikpok_tile_offset + (pikpok_tile_offset - red_police.tile)
