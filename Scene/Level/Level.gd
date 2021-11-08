extends Node2D

var heart_collectable_scene = preload("res://Scene/Collectables/HeartCollectable.tscn")

onready var spawner_container = $SpawnerContainer
onready var walls = $Navigation2D/Walls

class Difficulty:
	var nb_waves : int = 1
	var nb_enemies_per_wave : int = 4
	var wave_cooldown = 0.0
	var enemy_prob_array : Array = []
	
	func _init(_nb_waves: int, nb_enemies: int, cooldown: float = 0.0, 
			_enemy_prob_array : Array = [EnemyProb.new(1.0, "Bat")]):
		
		nb_waves = _nb_waves
		nb_enemies_per_wave = nb_enemies
		wave_cooldown = cooldown
		enemy_prob_array = _enemy_prob_array


class EnemyProb:
	var chance_to_appear : float = 1.0
	var enemy_scene : PackedScene = null
	
	func _init(chance: float, enemy_name: String) -> void:
		chance_to_appear = chance
		enemy_scene = GAME.enemy_dict[enemy_name]


var difficulty_levels = [
	Difficulty.new(1, 4),
	Difficulty.new(3, 6, 0.0, [EnemyProb.new(5.0, "Bat"), EnemyProb.new(1.0, "Squid")]),
	Difficulty.new(5, 8, 30.0, [EnemyProb.new(5.0, "Bat"), EnemyProb.new(1.0, "Squid")]),
	Difficulty.new(999, 5, 10.0, [EnemyProb.new(5.0, "Bat"), EnemyProb.new(2.0, "Squid")]),
	Difficulty.new(0, 0, 0.0)
]


var wave_counter : int = 0
var current_difficulty : Difficulty = null

#### ACCESSORS ####



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
		if child is Enemy && child.hp != 0:
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
		
		var enemy_prob_array = current_difficulty.enemy_prob_array
		var rdm_value = rand_range(0.0, _sum_prob(enemy_prob_array))
		var enemy_id = _get_prob_id(rdm_value, enemy_prob_array)
		var enemy_scene = enemy_prob_array[enemy_id].enemy_scene
		var enemy = enemy_scene.instance()
		
		spawner.spawn(enemy)


func _sum_prob(enemy_prob_array: Array) -> float:
	var sum = 0.0
	for enemy_prob in enemy_prob_array:
		sum += enemy_prob.chance_to_appear
	return sum


func _get_prob_id(value: float, enemy_prob_array: Array) -> int:
	var min_value = 0.0
	
	for i in range(enemy_prob_array.size()):
		var enemy_prob = enemy_prob_array[i]
		var max_value = min_value + enemy_prob.chance_to_appear
		
		if value >= min_value && value < max_value:
			return i
		
		min_value = max_value
	
	return 0


#### INPUTS ####


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		$Debug/Debug.set_visible(!$Debug/Debug.is_visible())


#### SIGNAL RESPONSES ####

func _on_EVENTS_spawn_heart(pos: Vector2) -> void:
	var heart = heart_collectable_scene.instance()
	heart.set_position(pos)
	
	call_deferred("add_child", heart)


func _on_EVENTS_enemy_killed(_points: int) -> void:
	if current_difficulty == null:
		return
	
	var nb_enemies = get_enemies_count()
	if nb_enemies == 0:
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
