extends Navigation2D

onready var walls = $Walls

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("enemy_spawn_query", self, "_on_EVENTS_enemy_spawn_query")

#### VIRTUALS ####



#### LOGIC ####

func is_position_valid(pos: Vector2) -> bool:
	var cell = walls.world_to_map(pos)
	var tile_id = walls.get_cellv(cell)
	
	if tile_id == -1:
		return false
	
	var tile_name = walls.get_tileset().tile_get_name(tile_id)
	
	return tile_name == "EmptyTile"


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_enemy_spawn_query(enemy: Enemy, pos: Vector2) -> void:
	enemy.set_position(pos)
	call_deferred("add_child", enemy)
