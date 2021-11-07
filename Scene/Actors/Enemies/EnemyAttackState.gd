extends StateBase
class_name EnemyAttackState

export var min_cooldown : float = 2.0
export var max_cooldown : float = 3.0

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	var __ = $Preparation.connect("timeout", self, "_on_Preparation_timeout")

#### VIRTUALS ####



#### LOGIC ####

func enter_state() -> void:
	owner.path = PoolVector2Array()
	owner.velocity = Vector2.ZERO
	$Preparation.start()


func exit_state() -> void:
	$AttackCooldown.start(rand_range(min_cooldown, max_cooldown))



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_Preparation_timeout() -> void:
	pass
