class_name GameManager extends Node

const LIVES_MIN: int = 0
const LIVES_MAX: int = 8

enum GhostMode {
	CHASE,
	SCATTER,
	FRIGHTENED,
}
enum Mode {
	NONE,
	PLAYING,
	OVER,
}

var ghost_mode: GhostMode = GhostMode.SCATTER:
	set(gm):
		if !GhostMode.values().has(gm) or ghost_mode == gm:
			return
		ghost_mode = gm
		ghost_mode_changed.emit(gm)
var lives: int = 3:
	set(l):
		if l < LIVES_MIN or l > LIVES_MAX or l == lives:
			return
		lives = l
		lives_changed.emit(l)
		
		if l == LIVES_MIN:
			mode = Mode.OVER
var mode: Mode = Mode.NONE:
	set(m):
		if !Mode.values().has(m) or m == mode:
			return
		mode = m
		mode_changed.emit(m)
		if m == Mode.PLAYING:
			SS.stats.score = 0

signal ghost_mode_changed(ghost_mode: GhostMode)
signal lives_changed(lives: int)
signal mode_changed(mode: Mode)
signal reset

func _ready() -> void:
	reset.connect(on_reset)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('dev_lives_decrease'):
		lives -= 1
	elif event.is_action_pressed('dev_lives_increase'):
		lives += 1
	if event.is_action_pressed('dev_mode_none'):
		mode = Mode.NONE
	if event.is_action_pressed('dev_mode_playing'):
		mode = Mode.PLAYING
	if event.is_action_pressed('dev_mode_over'):
		mode = Mode.OVER
	if event.is_action_pressed('dev_reset'):
		reset.emit()

func on_reset() -> void:
	mode = Mode.NONE
	SS.stats.score = 0
