extends EnemyAttackState

#### ACCESSORS ####


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_Preparation_timeout() -> void:
	for dir in Utils.DIRECTIONS_8.values():
		EVENTS.emit_signal("spawn_projectile", "Bullet", owner.get_global_position(), dir)
