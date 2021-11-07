extends Navigation2D

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("enemy_spawn_query", self, "_on_EVENTS_enemy_spawn_query")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_enemy_spawn_query(enemy: Enemy, pos: Vector2) -> void:
	enemy.set_position(pos)
	call_deferred("add_child", enemy)
