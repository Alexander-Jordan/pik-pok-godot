class_name PoliceManager extends Node2D

@export var audio_stream_fright: AudioStream
@export var audio_stream_retreat: AudioStream
@export var audio_stream_siren_1: AudioStream
@export var audio_stream_siren_2: AudioStream
@export var audio_stream_siren_3: AudioStream
@export var audio_stream_siren_4: AudioStream
@export var audio_stream_siren_5: AudioStream

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

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
				set_mode_and_duration(GM.PoliceMode.SCATTER, duration)
			2, 4:
				set_mode_and_duration(GM.PoliceMode.CHASE, 20.0)
			5:
				set_mode_and_duration(GM.PoliceMode.SCATTER, 5.0)
			6:
				var duration: float = 1037.0
				if GM.level == 1:
					duration = 20.0
				elif GM.level < 5:
					duration = 1033.0
				set_mode_and_duration(GM.PoliceMode.CHASE, duration)
			7:
				var duration: float = 7.0 if GM.level == 1 else 0.05
				set_mode_and_duration(GM.PoliceMode.SCATTER, duration)
			_:
				set_mode_and_duration(GM.PoliceMode.CHASE, 0.0)

@onready var timer_mode: Timer = $timer_mode

func _ready() -> void:
	GM.police_frighten_changed.connect(on_police_frighten_changed)
	GM.police_retreating_changed.connect(on_police_retreating_changed)
	GM.level_changed.connect(on_level_changed)
	GM.mode_changed.connect(on_game_mode_changed)
	GM.reset.connect(on_reset)
	timer_mode.timeout.connect(on_timer_mode_timeout)

func on_game_mode_changed(mode: GM.Mode) -> void:
	match mode:
		GM.Mode.PLAYING:
			on_police_normal()
			mode_index = 1
		_:
			audio_stream_player_2d.stop()

func on_police_frighten_changed(amount: int) -> void:
	if GM.police_retreating > 0:
		return
	
	if amount > 0:
		if audio_stream_player_2d.stream != audio_stream_fright:
			audio_stream_player_2d.stream = audio_stream_fright
			audio_stream_player_2d.play()
		return
	
	on_police_normal()

func on_police_retreating_changed(amount: int) -> void:
	if amount > 0:
		if audio_stream_player_2d.stream != audio_stream_retreat:
			audio_stream_player_2d.stream = audio_stream_retreat
			audio_stream_player_2d.play()
		return
	
	if GM.police_frighten > 0:
		if audio_stream_player_2d.stream != audio_stream_fright:
			audio_stream_player_2d.stream = audio_stream_fright
			audio_stream_player_2d.play()
		return
	
	on_police_normal()

func on_police_normal() -> void:
	match GM.super_money_collected:
		0:
			audio_stream_player_2d.stream = audio_stream_siren_1
		1:
			audio_stream_player_2d.stream = audio_stream_siren_2
		2:
			audio_stream_player_2d.stream = audio_stream_siren_3
		3:
			audio_stream_player_2d.stream = audio_stream_siren_4
		_:
			audio_stream_player_2d.stream = audio_stream_siren_5
	audio_stream_player_2d.play()

func on_level_changed(_level: int) -> void:
	mode_index = 0

func on_reset(_type: GM.ResetType) -> void:
	mode_index = 0

func on_timer_mode_timeout() -> void:
	mode_index += 1

func set_mode_and_duration(mode: GM.PoliceMode, duration: float) -> void:
	GM.police_mode = mode
	if duration > 0.0:
		timer_mode.start(duration)
