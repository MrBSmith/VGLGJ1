extends Node

const TILE_SIZE = Vector2(16.0, 16.0)
var screen_size = Vector2(640, 360)

const KILL_SCORE_BONUS = 100

var kill_counter : int = 0

var combo : bool = false

var score : int = 0 setget set_score
var score_multiplier : float = 1.0

#### ACCESSORS ####

func set_score(value: int) -> void:
	if value != score:
		score = value
		EVENTS.emit_signal("score_changed", score)


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("enemy_killed", self, "_on_EVENTS_enemy_killed")


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_EVENTS_enemy_killed() -> void:
	kill_counter += 1
	$ScoreMultiplierTimer.start()
	set_score(score + int(KILL_SCORE_BONUS * score_multiplier))
	
	if kill_counter >= 5:
		combo = true
	
	if combo:
		score_multiplier += 0.5

func _on_ScoreMultiplierTimer_timeout() -> void:
	kill_counter = 0
	combo = false
