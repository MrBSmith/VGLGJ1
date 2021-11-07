extends Collectable
class_name HeartCollectable

#### ACCESSORS ####

func is_class(value: String): return value == "HeartCollectable" or .is_class(value)
func get_class() -> String: return "HeartCollectable"


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####



#### LOGIC ####

func collect(_target: Node) -> void:
	.collect(_target)
	target.set_hp(target.hp + 1)
	queue_free()

#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_BeatCooldown_timeout() -> void:
	$AnimatedSprite.play("Beat")


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.get_animation() == "Beat":
		$AnimatedSprite.play("Idle")
		$BeatCooldown.start()
