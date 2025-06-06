class_name Collectable2D
extends Area2D
## A simple component to make anything a collectable.

#region VARIABLES
## The identifier for this collectable.
@export var identifier: String = ''
## The audio stream to be played when this collectable is collected.
@export var audio_streams: Array[AudioStream] = []
#endregion

#region SIGNALS
## Emitted when the collectable has been collected.
signal collected
#endregion

#region FUNCTIONS
## To be called by a collector when this collectable is to be collected.
func collect() -> void:
	collected.emit()

## To be called by a collector that plays an audio when this collectable is collected.
func get_audio() -> AudioStream:
	if audio_streams.is_empty():
		return null
	return audio_streams.pick_random()
#endregion
