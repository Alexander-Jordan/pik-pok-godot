class_name GhostManager extends Node2D

var mode_index: int = 0:
	set(mi):
		if mi < 0 or mi == mode_index:
			return
		mode_index = mi
		
		match mi:
			0:
				timer_mode.stop()
			1, 3:
				var duration: float = 7.0 if GM.level < 5 else 5.0
				set_mode_and_duration(GM.GhostMode.SCATTER, duration)
			2, 4:
				set_mode_and_duration(GM.GhostMode.CHASE, 20.0)
			5:
				set_mode_and_duration(GM.GhostMode.SCATTER, 5.0)
			6:
				var duration: float = 1037.0
				if GM.level == 1:
					duration = 20.0
				elif GM.level < 5:
					duration = 1033.0
				set_mode_and_duration(GM.GhostMode.CHASE, duration)
			7:
				var duration: float = 7.0 if GM.level == 1 else 0.05
				set_mode_and_duration(GM.GhostMode.SCATTER, duration)
			_:
				set_mode_and_duration(GM.GhostMode.CHASE, 0.0)

@onready var timer_mode: Timer = $timer_mode

func _ready() -> void:
	GM.level_changed.connect(on_level_changed)
	GM.mode_changed.connect(on_game_mode_changed)
	GM.reset.connect(on_reset)
	timer_mode.timeout.connect(on_timer_mode_timeout)

func on_game_mode_changed(mode: GM.Mode) -> void:
	match mode:
		GM.Mode.PLAYING:
			mode_index = 1

func on_level_changed(_level: int) -> void:
	mode_index = 0

func on_reset(_type: GM.ResetType) -> void:
	mode_index = 0

func on_timer_mode_timeout() -> void:
	mode_index += 1

func set_mode_and_duration(mode: GM.GhostMode, duration: float) -> void:
	GM.ghost_mode = mode
	if duration > 0.0:
		timer_mode.start(duration)
