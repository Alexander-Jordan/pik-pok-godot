class_name SuperMoney extends Money

const TIME_DEFAULT: float = 10.0
const TIME_LAST_LEVEL: int = 19

var time: float = TIME_DEFAULT:
	get = get_time

func on_collected() -> void:
	super()
	GM.super_money_collected += 1
	if time > 0.0:
		GM.police_frighten_time.emit(time)

static func get_time() -> float:
	var t: float = roundf(TIME_DEFAULT * (TIME_LAST_LEVEL - GM.level) / float(TIME_LAST_LEVEL))
	return 0.0 if t <= 0.0 else t
