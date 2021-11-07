extends Enemy
class_name Squid


#### ACCESSORS ####

func is_class(value: String): return value == "Squid" or .is_class(value)
func get_class() -> String: return "Squid"


#### BUILT-IN ####

func _physics_process(delta: float) -> void:
	if !path.empty() && !is_behaviour_state("Dead"):
		set_state("Move")
		_move_along_path(delta)

#### VIRTUALS ####



#### LOGIC ####

func die() -> void:
	.die()
	
	$CollisionShape2D.set_disabled(true)
	set_behaviour_state("Dead")
	set_state("Die")


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.get_animation() == "Die":
		queue_free()


func _on_AttackArea_body_exited(body: Node) -> void:
	if body is Player:
		_chase(body)



