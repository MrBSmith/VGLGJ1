extends Projectile
class_name Bullet

#### ACCESSORS ####

func is_class(value: String): return value == "Bullet" or .is_class(value)
func get_class() -> String: return "Bullet"


#### BUILT-IN ####

func _physics_process(delta: float) -> void:
	var velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision != null:
		var collider = collision.collider
		
		if collider != null:
			_explode()
			
			if collider is Actor:
				collider.hurt()

#### VIRTUALS ####



#### LOGIC ####

func _explode() -> void:
	$AnimatedSprite.play("Explode")
	set_physics_process(false)
	$CollisionShape2D.set_disabled(true)


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.get_animation() == "Explode":
		queue_free()
