class_name UIGame extends Control

@onready var label_highscore: Label = $VBoxContainer/hboxcontainer_top/margincontainer_highscore/VBoxContainer/label_highscore
@onready var label_score: Label = $VBoxContainer/hboxcontainer_top/margincontainer_score/VBoxContainer/label_score
@onready var texturerect_life_1: TextureRect = $VBoxContainer/hboxcontainer_bottom/margincontainer_lives/HBoxContainer/texturerect_life_1
@onready var texturerect_life_2: TextureRect = $VBoxContainer/hboxcontainer_bottom/margincontainer_lives/HBoxContainer/texturerect_life_2
@onready var texturerect_life_3: TextureRect = $VBoxContainer/hboxcontainer_bottom/margincontainer_lives/HBoxContainer/texturerect_life_3

func _ready() -> void:
	SS.stats.highscore_changed.connect(on_hichscore_changed)
	SS.stats.score_changed.connect(on_score_changed)
	
	label_highscore.text = "%02d" % SS.stats.highscore

func on_hichscore_changed(highscore: int) -> void:
	print(highscore)
	label_highscore.text = "%02d" % highscore

func on_score_changed(score: int) -> void:
	label_score.text = "%02d" % score
