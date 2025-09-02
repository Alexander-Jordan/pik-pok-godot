class_name GameManager extends Node

const LIVES_MIN: int = 0
const LIVES_MAX: int = 8

enum PoliceMode {
	CHASE,
	SCATTER,
}
enum Mode {
	NONE,
	PLAYING,
	CLEAR,
	DEATH,
	WAIT,
	OVER,
}
enum ResetType {
	GAME,
	LEVEL,
	LIFE,
}

var money_collected: int = 0:
	set(mc):
		if money_collected < 0 or mc == money_collected:
			return
		money_collected = mc
		if mc == 244:
			GM.mode = GM.Mode.CLEAR
			await get_tree().create_timer(1.0).timeout
			level += 1
var police_frighten: int = 0:
	set(pf):
		if pf < 0 or pf == police_frighten:
			return
		police_frighten = pf
		police_frighten_changed.emit(pf)
var police_mode: PoliceMode = PoliceMode.SCATTER:
	set(pm):
		if !PoliceMode.values().has(pm) or police_mode == pm:
			return
		police_mode = pm
		police_mode_changed.emit(pm)
var police_retreating: int = 0:
	set(pr):
		if pr < 0 or pr == police_retreating:
			return
		police_retreating = pr
		police_retreating_changed.emit(pr)
var level: int = 1:
	set(l):
		if l < 1 or l == level:
			return
		level = l
		level_changed.emit(l)
		if mode == Mode.NONE:
			return
		
		reset.emit(ResetType.LEVEL)
		await get_tree().create_timer(1.0).timeout
		mode = Mode.PLAYING
var lives: int = 3:
	set(l):
		if l < LIVES_MIN or l > LIVES_MAX or l == lives:
			return
		lives = l
		lives_changed.emit(l)
		if mode == Mode.NONE:
			return
		
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
var super_money_collected: int = 0

signal police_frighten_changed(amount: int)
signal police_mode_changed(police_mode: PoliceMode)
signal police_retreating_changed(amount: int)
signal police_frighten_time(time: float)
signal level_changed(level: int)
signal lives_changed(lives: int)
signal mode_changed(mode: Mode)
signal reset(type: ResetType)

func _ready() -> void:
	reset.connect(on_reset)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('dev_police_frighten_time'):
		police_frighten_time.emit(SuperMoney.get_time())
	elif event.is_action_pressed('dev_police_frighten_time_default'):
		police_frighten_time.emit(10.0)
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
	SS.save_stats()
	if type == ResetType.LIFE:
		return
	money_collected = 0
	mode = Mode.NONE
	super_money_collected = 0
	if type == ResetType.GAME:
		level = 1
		lives = 3
		SS.stats.score = 0
