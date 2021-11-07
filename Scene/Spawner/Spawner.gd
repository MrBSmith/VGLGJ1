extends Node2D

onready var animated_sprite = $AnimatedSprite

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	set_visible(false)


#### VIRTUALS ####



#### LOGIC ####

func spawn(enemy: Enemy) -> void:
	animated_sprite.play("Appear")
	set_visible(true)
	
	yield(animated_sprite, "animation_finished")
	animated_sprite.play("Idle")
	
	yield(get_tree().create_timer(2), "timeout")
	
	EVENTS.emit_signal("enemy_spawn_query", enemy, get_global_position())
	
	yield(get_tree().create_timer(1), "timeout")
	animated_sprite.play("Disappear")
	
	yield(animated_sprite, "animation_finished")
	set_visible(false)


#### INPUTS ####



#### SIGNAL RESPONSES ####
