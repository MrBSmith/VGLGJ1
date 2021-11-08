extends Projectile
class_name Kunai



#### ACCESSORS ####

func is_class(value: String): return value == "Kunai" or .is_class(value)
func get_class() -> String: return "Kunai"

func set_state(value: String) -> void: $StatesMachine.set_state(value)
func is_state(value: String) -> bool: return $StatesMachine.get_state_name() == value

#### BUILT-IN ####

func _ready() -> void:
	set_rotation(direction.angle())


func _physics_process(delta: float) -> void:
	if is_state("Fall"):
		velocity.y += gravity
		rotation_degrees += 10
	else:
		velocity = direction * speed
	
	var collision = move_and_collide(velocity * delta)
	
	if collision != null:
		var collider = collision.collider
		
		if collider is TileMap and collider.name == "Walls":
			set_state("Collectable")
		else:
			if collider.is_class("Enemy") && is_state("Projectile"):
				collider.hurt(collision.position)
				set_state("Fall")


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_class("Player") && is_state("Collectable"):
		EVENTS.emit_signal("collect_kunai")
		queue_free()


func _on_StatesMachine_state_changed(state) -> void:
	if state.name != "Projectile":
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
