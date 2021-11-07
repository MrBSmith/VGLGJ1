extends Node2D


var heart_collectable_scene = preload("res://Scene/Collectables/HeartCollectable.tscn")

onready var spawner_container = $SpawnerContainer
onready var walls = $Navigation2D/Walls

class Difficulty:
	var nb_waves : int = 1
	var nb_enemies_per_wave : int = 4
	var wave_cooldown = 0.0
	var enemy_scenes = []
	
	func _init(_nb_waves: int, nb_enemies: int, cooldown: float = 0.0, enemy_scenes_array : Array = ["res://Scene/Actors/Enemies/Bat.tscn"]):
		nb_waves = _nb_waves
		nb_enemies_per_wave = nb_enemies
		wave_cooldown = cooldown
		enemy_scenes = enemy_scenes_array


var difficulty_levels = [
	Difficulty.new(1, 4),
	Difficulty.new(3, 6),
	Difficulty.new(5, 8, 30.0),
	Difficulty.new(999, 5, 10.0),
	Difficulty.new(0, 0, 0.0)
]


var wave_counter : int = 0
var current_difficulty : Difficulty = null

#### ACCESSORS ####

func is_class(value: String): return value == "" or .is_class(value)
func get_class() -> String: return ""


#### BUILT-IN ####

func _ready() -> void:
	randomize()
	
	var __ = EVENTS.connect("enemy_killed", self, "_on_EVENTS_enemy_killed")
	__ = EVENTS.connect("new_difficulty", self, "_on_EVENTS_new_difficulty")
	__ = EVENTS.connect("gameover", self, "_on_EVENTS_gameover")
	__ = EVENTS.connect("spawn_heart", self, "_on_EVENTS_spawn_heart")
	
	if GAME.difficulty != GAME.DIFFICULTY.NONE:
		new_difficulty(GAME.difficulty)




#### VIRTUALS ####



#### LOGIC ####


func get_enemies_count() -> int:
	var counter = 0
	for child in $Navigation2D.get_children():
		if child is Enemy && child.get_behaviour_state_name() != "Dead":
			counter += 1
	return counter


func new_difficulty(difficulty: int) -> void:
	current_difficulty = difficulty_levels[difficulty]
	wave_counter = 0
	new_wave()


func new_wave() -> void:
	wave_counter += 1
	if current_difficulty.wave_cooldown != 0.0:
		$WaveCooldown.start(current_difficulty.wave_cooldown)
	
	EVENTS.emit_signal("wave_started", wave_counter)
	
	var spawner_array = spawner_container.get_children()
	
	for _i in range(current_difficulty.nb_enemies_per_wave):
		var rdm_id = Math.randi_range(0, spawner_array.size() - 1)
		var spawner = spawner_array[rdm_id]
		spawner_array.remove(rdm_id)
		
		var rdm_enemy_id = Math.randi_range(0, current_difficulty.enemy_scenes.size() - 1)
		var enemy_scene = load(current_difficulty.enemy_scenes[rdm_enemy_id])
		var enemy = enemy_scene.instance()
		
		spawner.spawn(enemy)



#### INPUTS ####


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		$Debug/Debug.set_visible(!$Debug/Debug.is_visible())


#### SIGNAL RESPONSES ####

func _on_EVENTS_spawn_heart(pos: Vector2) -> void:
	var heart = heart_collectable_scene.instance()
	heart.set_position(pos)
	
	call_deferred("add_child", heart)


func _on_EVENTS_enemy_killed() -> void:
	if current_difficulty == null:
		return
	
	if get_enemies_count() == 0:
		if wave_counter >= current_difficulty.nb_waves:
			EVENTS.emit_signal("difficulty_finished")
		else:
			new_wave()


func _on_EVENTS_new_difficulty(difficulty: int) -> void:
	new_difficulty(difficulty)


func _on_EVENTS_gameover() -> void:
	$UI.add_child(GAME.gameover_scene.instance())


func _on_WaveCooldown_timeout() -> void:
	new_wave()
