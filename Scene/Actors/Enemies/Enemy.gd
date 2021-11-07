extends Actor
class_name Enemy

export var points : int = 100

export var speed : float = 150.0

onready var new_attack_attempt_timer = $BehaviourState/Attack/NewAttemptTimer
onready var wanter_wait_timer = $BehaviourState/Wander/WaitTimer
onready var attack_cooldown = $BehaviourState/Attack/AttackCooldown

export var wander_distance = 80.0
export var min_wander_wait_time : float = 1.0
export var max_wander_wait_time : float = 4.0

var path := PoolVector2Array()
var target : KinematicBody2D = null setget set_target

signal path_finished


#### ACCESSORS ####

func is_class(value: String): return value == "Enemy" or .is_class(value)
func get_class() -> String: return "Enemy"

func set_behaviour_state(state_name: String) -> void: $BehaviourState.set_state(state_name)
func get_behaviour_state() -> StateBase: return $BehaviourState.get_state()
func get_behaviour_state_name() -> String: return $BehaviourState.get_state_name()
func is_behaviour_state(value: String) -> bool: return get_behaviour_state_name() == value

func set_target(value: KinematicBody2D) -> void:
	target = value

#### BUILT-IN ####


func _ready() -> void:
	var __ = $AggroArea.connect("body_entered", self, "_on_AggroArea_body_entered")
	__ = $BehaviourState/Wander/WaitTimer.connect("timeout", self, "_on_WaitTimer_timeout")
	__ = connect("path_finished", self, "_on_path_finished")
	__ = $ViewFieldArea.connect("body_exited", self, "_on_ViewFieldArea_body_exited")
	__ = $BehaviourState/Chase/ChasePathUpdateTimer.connect("timeout", self, "_on_ChasePathUpdateTimer_timeout")
	__ = $AttackArea.connect("body_entered", self, "_on_AttackArea_body_entered")
	__ = $BehaviourState/Attack/AttackCooldown.connect("timeout", self, "_on_AttackCooldown_timeout")
	__ = $StatesMachine/Hurt.connect("state_animation_finished", self, "_on_Hurt_state_animation_finished")
	__ = new_attack_attempt_timer.connect("timeout", self, "_on_NewAttemptTimer_timeout")

#### VIRTUALS ####



#### LOGIC ####


func _move_along_path(delta: float) -> void:
	if is_behaviour_state("Dead"):
		return
	
	var next_point = path[0]
	var dir = global_position.direction_to(next_point)
	var dist = global_position.distance_to(next_point)
	var applied_spd = speed * delta
	
	if dist > applied_spd:
		velocity = dir * speed
		velocity = move_and_slide(velocity)
	else:
		set_global_position(next_point)
		
		path.remove(0)
		if path.empty():
			emit_signal("path_finished")


func wander() -> void:
	if is_behaviour_state("Dead"):
		return
	
	set_behaviour_state("Wander")
	
	var dest_pos = _get_rdm_wander_position()
	var global_pos = get_global_position()
	path = get_parent().get_simple_path(global_pos, dest_pos)
	path.remove(0)


func _chase(node: KinematicBody2D) -> void:
	if is_behaviour_state("Dead") or node == null:
		return
	
	set_behaviour_state("Chase")
	set_target(node)
	_update_chase_path()


func _update_chase_path() -> void:
	if target == null or is_behaviour_state("Dead"):
		return
	
	path = get_parent().get_simple_path(get_global_position(), target.get_global_position())


func _get_rdm_wander_position() -> Vector2:
	var result_pos = -Vector2.ONE
	
	while(!get_parent().is_position_valid(result_pos)):
		var rdm_angle = deg2rad(rand_range(0.0, 360.0))
		var dir = Vector2(sin(rdm_angle), cos(rdm_angle))
		var dist = rand_range(wander_distance / 2, wander_distance)
		result_pos = to_global(dir * dist)
	
	return result_pos


func die() -> void:
	var rng = Math.randi_range(0, 30 * (GAME.difficulty + 1))
	
	if rng == 0:
		EVENTS.emit_signal("spawn_heart", get_global_position())


func hurt() -> void:
	EVENTS.emit_signal("screen_shake", 1.5, 0.25)
	.hurt()


func can_attack() -> bool:
	if target == null:
		return false
	
	if !attack_cooldown.is_stopped() and !attack_cooldown.is_paused():
		return false
	
	return true


func _attack_attempt() -> void:
	if is_behaviour_state("Dead"):
		return
	
	new_attack_attempt_timer.start()
	
	if can_attack():
		_attack()



func _attack() -> void:
	set_behaviour_state("Attack")
	set_state("Attack")


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_AggroArea_body_entered(body: Node) -> void:
	if body is Player && is_behaviour_state("Wander"):
		_chase(body)


func _on_WaitTimer_timeout() -> void:
	if is_behaviour_state("Wander"):
		wander()


func _on_path_finished() -> void:
	if is_behaviour_state("Wander"):
		wanter_wait_timer.start(rand_range(min_wander_wait_time, max_wander_wait_time))


func _on_ViewFieldArea_body_exited(body: Node) -> void:
	if body is Player && !is_behaviour_state("Dead"):
		set_target(null)
		wander()


func _on_ChasePathUpdateTimer_timeout() -> void:
	if is_behaviour_state("Chase"):
		_update_chase_path()


func _on_AttackArea_body_entered(body: Node) -> void:
	if body is Player:
		_attack_attempt()


func _on_AttackCooldown_timeout() -> void:
	_attack_attempt()


func _on_Hurt_state_animation_finished() -> void:
	if hp <= 0:
		die()


func _on_NewAttemptTimer_timeout() -> void:
	_attack_attempt()
