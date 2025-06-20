class_name GameManager extends Node

const LIVES_MIN: int = 0
const LIVES_MAX: int = 8

enum GhostMode {
	CHASE,
	SCATTER,
}
enum Mode {
	NONE,
	PLAYING,
	DEATH,
	WAIT,
	OVER,
}
enum ResetType {
	GAME,
	LEVEL,
	LIFE,
}

var dots_collected: int = 0:
	set(dc):
		if dots_collected < 0 or dc == dots_collected:
			return
		dots_collected = dc
		if dc == 244:
			level += 1
var ghost_mode: GhostMode = GhostMode.SCATTER:
	set(gm):
		if !GhostMode.values().has(gm) or ghost_mode == gm:
			return
		ghost_mode = gm
		ghost_mode_changed.emit(gm)
var level: int = 1:
	set(l):
		if l < 1 or l == level:
			return
		level = l
		level_changed.emit(l)
		
		mode = Mode.WAIT
		await get_tree().create_timer(2.0).timeout
		reset.emit(ResetType.LEVEL)
		mode = Mode.PLAYING
var lives: int = 3:
	set(l):
		if l < LIVES_MIN or l > LIVES_MAX or l == lives:
			return
		lives = l
		lives_changed.emit(l)
		
		if l > LIVES_MIN:
			reset.emit(ResetType.LIFE)
			await get_tree().create_timer(1.0).timeout
			mode = Mode.PLAYING
		else:
			mode = Mode.OVER
var mode: Mode = Mode.NONE:
	set(m):
		if !Mode.values().has(m) or m == mode:
			return
		mode = m
		mode_changed.emit(m)

signal ghost_mode_changed(ghost_mode: GhostMode)
signal ghost_frighten_time(time: float)
signal level_changed(level: int)
signal lives_changed(lives: int)
signal mode_changed(mode: Mode)
signal reset(type: ResetType)

func _ready() -> void:
	reset.connect(on_reset)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('dev_ghost_frighten_time'):
		ghost_frighten_time.emit(PowerPellet.get_time())
	elif event.is_action_pressed('dev_ghost_frighten_time_default'):
		ghost_frighten_time.emit(10.0)
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
	if event.is_action_pressed('dev_reset_level'):
		reset.emit(ResetType.LEVEL)
	elif event.is_action_pressed('dev_reset_game'):
		reset.emit(ResetType.GAME)

func on_reset(type: ResetType) -> void:
	if type == ResetType.LIFE:
		return
	dots_collected = 0
	mode = Mode.NONE
	if type == ResetType.GAME:
		level = 1
		SS.stats.score = 0
