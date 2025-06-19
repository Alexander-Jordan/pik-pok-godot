class_name PowerPellet extends Pacdot

const TIME_DEFAULT: float = 10.0
const TIME_LAST_LEVEL: int = 19

var time: float = TIME_DEFAULT:
	get = get_time

func on_collected() -> void:
	super()
	if time > 0.0:
		GM.ghost_frighten_time.emit(time)

static func get_time() -> float:
	var t: float = roundf(TIME_DEFAULT * (TIME_LAST_LEVEL - GM.level) / float(TIME_LAST_LEVEL))
	return 0.0 if t <= 0.0 else t
