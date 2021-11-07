extends Node2D

onready var spawner_container = $SpawnerContainer
onready var walls = $Walls
onready var nav_polygon_instance = $Navigation2D/NavigationPolygonInstance

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
	Difficulty.new(999, 5, 10.0)
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
	
	new_difficulty(GAME.difficulty)




#### VIRTUALS ####



#### LOGIC ####

func exclude_tiles_from_nav_poly() -> void:
	var nav_polygon = nav_polygon_instance.get_navigation_polygon()
	
	var adj_groups_array = sort_cells_by_adjacents()
	
	for group in adj_groups_array:
		var group_polygon = get_group_polygon(group)
		nav_polygon.add_outline(group_polygon)
		nav_polygon.make_polygons_from_outlines()

	nav_polygon_instance.set_navigation_polygon(nav_polygon)


func sort_cells_by_adjacents() -> Array:
	var cell_group_array = []
	
	for cell in walls.get_used_cells():
		if cell.x < 1 or cell.y < 1 or cell.x > 38 or cell.y > 21:
			continue
		
		var group_found : bool = false
		
		if cell_group_array.empty():
			cell_group_array.append([])
		
		for group in cell_group_array:
			if group.empty():
				group.append(cell)
				group_found = true
				break
			else:
				if is_cell_adj_to_group(group, cell):
					group.append(cell)
					group_found = true
					break
		
		if !group_found:
			cell_group_array.append([cell])
	
	return cell_group_array


func is_cell_adj_to_group(group: Array, cell: Vector2) -> bool:
	for group_cell in group:
		var adj = [ group_cell + Vector2.RIGHT,
					group_cell + Vector2.LEFT,
					group_cell + Vector2.UP,
					group_cell + Vector2.DOWN]
		
		if cell in adj:
			return true
	return false


func get_group_polygon(group: Array) -> PoolVector2Array:
	var group_polygon = PoolVector2Array()
	for cell in group:
		var cell_id = walls.get_cellv(cell)
		var cell_nav_poly = walls.get_tileset().autotile_get_navigation_polygon(cell_id, Vector2.RIGHT).get_vertices()
		
		for vertex in cell_nav_poly:
			var final_vertex = vertex + cell * GAME.TILE_SIZE
			if not final_vertex in group_polygon:
				group_polygon.append(final_vertex)
	
	return group_polygon


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

func _on_EVENTS_enemy_killed() -> void:
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
