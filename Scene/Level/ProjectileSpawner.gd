extends Node2D

var projectile_dict : Dictionary = {
	"Kunai": preload("res://Scene/Projectiles/Kunai/Kunai.tscn"),
	"Bullet" : preload("res://Scene/Projectiles/Bullet/Bullet.tscn")
}

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("spawn_projectile", self, "_on_EVENTS_spawn_projectile")


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_spawn_projectile(projectile_type: String, pos: Vector2, dir: Vector2) -> void:
	var projectile = projectile_dict[projectile_type].instance()
	projectile.set_position(pos)
	projectile.set_direction(dir)
	
	call_deferred("add_child", projectile)
