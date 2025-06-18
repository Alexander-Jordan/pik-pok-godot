class_name Inky extends Ghost

const TILES_AHEAD_OF_PACMAN: int = 2

@export var blinky: Blinky

func get_tile_target_during_chase() -> Vector2i:
	var pacman_tile_offset: Vector2i = pacman.tile + (pacman.look_direction * TILES_AHEAD_OF_PACMAN)
	return pacman_tile_offset + (pacman_tile_offset - blinky.tile)
