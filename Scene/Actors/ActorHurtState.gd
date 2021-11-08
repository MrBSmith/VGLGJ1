extends AnimatedObjectStateBase

var col_layer = 0

#### ACCESSORS ####

func is_class(value: String): return value == "" or .is_class(value)
func get_class() -> String: return ""


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####


func enter_state() -> void:
	col_layer = owner.get_collision_layer()
	owner.set_collision_layer(0)
	.enter_state()


func exit_state() -> void:
	owner.set_collision_layer(col_layer)
	.exit_state()

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_state_animation_finished() -> void:
	if toggle_state_mode && is_current_state():
		var previous_state = states_machine.previous_state
		if not previous_state.name in ["Attack", "Throw"]:
			states_machine.set_state(previous_state)
		else:
			states_machine.set_state("Idle")
