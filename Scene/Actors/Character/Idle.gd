extends AnimatedObjectStateBase

#### ACCESSORS ####


#### BUILT-IN ####



#### VIRTUALS ####

func enter_state() -> void:
	if states_machine.previous_state != null and states_machine.previous_state.name == "Fall":
		animated_sprite.play("Land")
	else:
		.enter_state()


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.get_animation() == "Land":
		.enter_state()
