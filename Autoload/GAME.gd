extends Node

const TILE_SIZE = Vector2(16.0, 16.0)
var screen_size = Vector2(640, 360)

const KILL_SCORE_BONUS = 100
var score : int = 0 setget set_score

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
	set_score(score + KILL_SCORE_BONUS)
