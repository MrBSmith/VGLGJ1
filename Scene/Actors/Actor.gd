extends KinematicBody2D
class_name Actor

export var max_hp : int = 1
onready var hp : int = max_hp setget set_hp

var velocity := Vector2.ZERO setget set_velocity

signal hp_changed

#### ACCESSORS ####

func is_class(value: String): return value == "Actor" or .is_class(value)
func get_class() -> String: return "Actor"

func set_hp(value: int) -> void:
	if value != hp:
		hp = value
		emit_signal("hp_changed")


func set_velocity(value: Vector2) -> void: velocity = value

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("hp_changed", self, "_on_hp_changed")

#### VIRTUALS ####



#### LOGIC ####

func hurt() -> void:
	set_hp(hp - 1)


func die() -> void:
	queue_free()

#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_hp_changed() -> void:
	if hp <= 0:
		die()
