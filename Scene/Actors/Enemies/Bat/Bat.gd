extends Enemy
class_name Bat

const DASH_SPEED : float = 600.0


#### ACCESSORS ####

func is_class(value: String): return value == "Bat" or .is_class(value)
func get_class() -> String: return "Bat"


#### BUILT-IN ####



func _physics_process(delta: float) -> void:
	if is_state("Fall"):
		velocity.y += gravity
		var __ = move_and_slide(velocity, Vector2.UP)
		
		if is_on_floor():
			set_state("Die")
	
	elif is_behaviour_state("Attack"):
		var collision = move_and_collide(velocity * delta)
		if collision != null:
			var collider = collision.collider
			
			if collider.is_class("Player"):
				collider.hurt(collision.position)
				_chase(collider)
	
	elif !path.empty():
		set_state("Move")
		_move_along_path(delta)


#### VIRTUALS ####


func _attack() -> void:
	if target == null or target.is_state("Die") or is_behaviour_state("Dead"):
		return
	
	$RayCast2D.set_cast_to(to_local(target.get_global_position()))
	
	if $RayCast2D.get_collider() == null:
		set_state("Attack")
		set_behaviour_state("Attack")


func die() -> void:
	.die()
	velocity = Vector2.ZERO
	path = []
	set_state("Fall")
	set_behaviour_state("Dead")


#### LOGIC ####




#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_AttackDuration_timeout() -> void:
	if is_behaviour_state("Attack"):
		_chase(target)

