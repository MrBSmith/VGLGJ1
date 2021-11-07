extends Actor
class_name Enemy

#### ACCESSORS ####

func is_class(value: String): return value == "Enemy" or .is_class(value)
func get_class() -> String: return "Enemy"



#### BUILT-IN ####


#### VIRTUALS ####



#### LOGIC ####

func die() -> void:
	var rng = Math.randi_range(0, 30 * (GAME.difficulty + 1))
	if rng == 0:
		EVENTS.emit_signal("spawn_heart", get_global_position())


func hurt() -> void:
	EVENTS.emit_signal("screen_shake", 1.5, 0.25)
	.hurt()


#### INPUTS ####



#### SIGNAL RESPONSES ####
