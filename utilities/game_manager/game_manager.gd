class_name GameManager extends Node

enum Mode {
	NONE,
	PLAYING,
	OVER,
}

var mode: Mode = Mode.NONE:
	set(m):
		if !Mode.values().has(m) or m == mode:
			return
		mode = m
		mode_changed.emit(m)

signal mode_changed(mode: Mode)
signal reset

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('dev_mode_none'):
		mode = Mode.NONE
	if event.is_action_pressed('dev_mode_playing'):
		mode = Mode.PLAYING
	if event.is_action_pressed('dev_mode_over'):
		mode = Mode.OVER
	if event.is_action_pressed('dev_reset'):
		reset.emit()
		mode = Mode.NONE
