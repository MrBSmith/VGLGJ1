extends KinematicBody2D
class_name Projectile

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
export var speed = 2000.0

var direction := Vector2.ZERO setget set_direction
var velocity := Vector2.ZERO

#### ACCESSORS ####

func is_class(value: String): return value == "Projetile" or .is_class(value)
func get_class() -> String: return "Projetile"

func set_direction(value: Vector2) -> void: direction = value


#### BUILT-IN ####





#### VIRTUALS ####



#### LOGIC ####




#### INPUTS ####



#### SIGNAL RESPONSES ####


