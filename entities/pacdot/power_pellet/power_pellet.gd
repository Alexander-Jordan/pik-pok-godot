class_name PowerPellet extends Pacdot

func on_collected() -> void:
	super()
	GM.ghost_frightened_changed.emit(true)
