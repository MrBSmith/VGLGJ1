extends Control

onready var score_label = $CenterContainer/VBoxContainer/VBoxContainer/Score
onready var enemies_killed_label = $CenterContainer/VBoxContainer/VBoxContainer/EnemiesKilled
onready var difficulty_label = $CenterContainer/VBoxContainer/VBoxContainer/Difficulty
onready var waves_label = $CenterContainer/VBoxContainer/VBoxContainer/EnemyWaves

onready var score_label_default_text = score_label.get_text()
onready var enemies_killed_label_default_text = enemies_killed_label.get_text()
onready var difficulty_label_default_text = difficulty_label.get_text()
onready var waves_label_default_text = waves_label.get_text()

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	score_label.set_text(score_label_default_text % GAME.score)
	enemies_killed_label.set_text(enemies_killed_label_default_text % GAME.total_enemies_killed)
	waves_label.set_text(waves_label_default_text % GAME.total_wave_counter)
	
	var difficulty_name = GAME.DIFFICULTY.keys()[GAME.difficulty].to_lower().capitalize()
	
	difficulty_label.set_text(difficulty_label_default_text % difficulty_name)
	


#### VIRTUALS ####



#### LOGIC ####

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		EVENTS.emit_signal("new_game")

#### INPUTS ####



#### SIGNAL RESPONSES ####
