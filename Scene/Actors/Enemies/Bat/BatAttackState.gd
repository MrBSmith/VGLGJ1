extends EnemyAttackState

#### ACCESSORS ####



#### BUILT-IN ####


#### VIRTUALS ####

func exit_state() -> void:
	if owner == null:
		return
	
	.enter_state()
	owner.set_collision_mask(0)


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_Preparation_timeout() -> void:
	if owner == null:
		return
	
	if owner.target == null:
		owner.set_behaviour_state("Wander")
		return
	
	var dir = owner.get_global_position().direction_to(owner.target.get_global_position())
	
	owner.velocity = dir * owner.DASH_SPEED
	$AttackDuration.start()
	owner.set_collision_mask(1)
