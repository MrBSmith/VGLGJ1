extends Node

enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD,
	IMPOSSIBLE,
	NONE
}

const TILE_SIZE = Vector2(16.0, 16.0)
var screen_size = Vector2(640, 360)

const KILL_SCORE_BONUS = 100

var kill_counter : int = 0
var gameover_scene = preload("res://Scene/UI/GameOver/GameOver.tscn")

export(DIFFICULTY) var difficulty : int = DIFFICULTY.EASY

var combo : bool = false

var score : int = 0 setget set_score
var score_multiplier : float = 1.0

var total_enemies_killed : int = 0
var total_wave_counter : int = 0

var wave_id : int = 0

#### ACCESSORS ####

func set_score(value: int) -> void:
	if value != score:
		score = value
		EVENTS.emit_signal("score_changed", score)


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("enemy_killed", self, "_on_EVENTS_enemy_killed")
	__ = EVENTS.connect("difficulty_finished", self, "_on_EVENTS_difficulty_finished")
	__ = EVENTS.connect("wave_started", self, "_on_EVENTS_wave_started")
	__ = EVENTS.connect("new_game", self, "_on_EVENTS_new_game")


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_EVENTS_enemy_killed() -> void:
	total_enemies_killed += 1
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


func _on_EVENTS_difficulty_finished() -> void:
	if difficulty < DIFFICULTY.IMPOSSIBLE:
		difficulty += 1
	
	EVENTS.emit_signal("new_difficulty", difficulty)


func _on_EVENTS_wave_started(_counter: int) -> void:
	total_wave_counter += 1


func _on_EVENTS_new_game() -> void:
	total_enemies_killed = 0
	total_wave_counter = 0
	kill_counter = 0
	wave_id = 0
	difficulty = DIFFICULTY.EASY
	combo = false
	score = 0
	
	var __ = get_tree().reload_current_scene()
