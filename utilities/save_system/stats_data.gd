class_name StatsData extends Resource
## All game stats data.

#region VARIABLES
## How many times has the game been booted?
@export var game_booted_count: int = 0
## The highest score set.
@export var highscore: int = 0:
	set(h):
		if h < 0 or h == highscore:
			return
		highscore = h
		highscore_changed.emit(h)
## The score of the current or last game.
@export var score: int = 0:
	set(s):
		if s < 0 or s == score:
			return
		
		score = s
		score_changed.emit(s)
		
		if s > highscore:
			highscore = s

signal highscore_changed(highscore: int)
signal score_changed(score: int)
#endregion
