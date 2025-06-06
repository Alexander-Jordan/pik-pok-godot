class_name Pacdot extends Spawnable2D

@export var points: int = 10

@onready var collectable_2d: Collectable2D = $Collectable2D

func _ready() -> void:
	collectable_2d.collected.connect(on_collected)

func on_collected() -> void:
	SS.stats.score += points
	despawn()
