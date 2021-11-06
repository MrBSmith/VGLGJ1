extends Node2D

var kunai_scene = preload("res://Scene/Kunai/Kunai.tscn")

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("spawn_kunai", self, "_on_EVENTS_spawn_kunai")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_spawn_kunai(pos: Vector2, dir: Vector2) -> void:
	var kunai = kunai_scene.instance()
	kunai.set_position(pos)
	kunai.set_direction(dir)
	
	call_deferred("add_child", kunai)
