extends KinematicBody2D
class_name Actor

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

onready var animated_sprite = get_node_or_null("AnimatedSprite")
onready var tween = $Tween

export var max_hp : int = 1
onready var hp : int = max_hp setget set_hp

var velocity := Vector2.ZERO setget set_velocity

signal hp_changed

#### ACCESSORS ####

func is_class(value: String): return value == "Actor" or .is_class(value)
func get_class() -> String: return "Actor"

func set_hp(value: int) -> void:
	if value != hp && value <= max_hp && value >= 0:
		hp = value
		emit_signal("hp_changed")


func set_velocity(value: Vector2) -> void: velocity = value

func set_state(state_name: String) -> void:$StatesMachine.set_state(state_name)
func get_state() -> StateBase: return $StatesMachine.get_state()
func get_state_name() -> String: return $StatesMachine.get_state_name()
func is_state(value: String) -> bool: return get_state_name() == value

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("hp_changed", self, "_on_hp_changed")


#### VIRTUALS ####



#### LOGIC ####

func hurt(impact_pos: Vector2) -> void:
	set_state("Hurt")
	set_hp(hp - 1)
	var dir = -get_global_position().direction_to(impact_pos)
	
	set_velocity(dir * 200.0)
	
	if !is_instance_valid(animated_sprite) or !is_instance_valid(tween):
		return
	
	tween.interpolate_property(animated_sprite.get_material(), "shader_param/mix_amount", 
		0.0, 1.0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
		
	tween.interpolate_property(animated_sprite.get_material(), "shader_param/mix_amount", 
		1.0, 0.0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	tween.start()



func die() -> void:
	queue_free()


func _attack() -> void:
	pass


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_hp_changed() -> void:
	if hp <= 0:
		die()


