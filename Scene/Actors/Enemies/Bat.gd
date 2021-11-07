extends Enemy
class_name Bat

onready var wanter_wait_timer = $BehaviourState/Wander/WaitTimer
onready var attack_cooldown = $BehaviourState/Attack/AttackCooldown

const SPEED = 150.0
const DASH_SPEED : float = 600.0

export var wander_distance = 80.0
export var min_wander_wait_time : float = 1.0
export var max_wander_wait_time : float = 4.0

var path := PoolVector2Array()
var target : KinematicBody2D = null

signal path_finished

#### ACCESSORS ####

func is_class(value: String): return value == "Bat" or .is_class(value)
func get_class() -> String: return "Bat"

func set_state(state_name: String) -> void:$StatesMachine.set_state(state_name)
func get_state() -> StateBase: return $StatesMachine.get_state()
func get_state_name() -> String: return $StatesMachine.get_state_name()
func is_state(value: String) -> bool: return get_state_name() == value

func set_behaviour_state(state_name: String) -> void: $BehaviourState.set_state(state_name)
func get_behaviour_state() -> StateBase: return $BehaviourState.get_state()
func get_behaviour_state_name() -> String: return $BehaviourState.get_state_name()
func is_behaviour_state(value: String) -> bool: return get_behaviour_state_name() == value


#### BUILT-IN ####



func _physics_process(delta: float) -> void:
	if is_state("Fall"):
		velocity.y += gravity
		var __ = move_and_slide(velocity, Vector2.UP)
		
		if is_on_floor():
			set_state("Die")
	
	elif is_behaviour_state("Attack"):
		var collision = move_and_collide(velocity * delta)
		if collision != null:
			var collider = collision.collider
			
			if collider.is_class("Player"):
				collider.hurt()
				_chase(target)
	
	elif !path.empty():
		set_state("Move")
		_move_along_path(delta)


#### VIRTUALS ####



#### LOGIC ####

func _move_along_path(delta: float) -> void:
	if is_behaviour_state("Dead"):
		return
	
	var next_point = path[0]
	var dir = global_position.direction_to(next_point)
	var dist = global_position.distance_to(next_point)
	var applied_spd = SPEED * delta
	
	if dist > applied_spd:
		velocity = dir * SPEED
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
	if is_behaviour_state("Dead"):
		return
	
	set_behaviour_state("Chase")
	target = node
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


func _attack() -> void:
	if target == null or target.is_state("Die") or is_behaviour_state("Dead"):
		return
	
	$RayCast2D.set_cast_to(to_local(target.get_global_position()))
	
	if $RayCast2D.get_collider() == null:
		set_state("Attack")
		set_behaviour_state("Attack")


func can_attack() -> bool:
	if target == null:
		return false
	
	if !attack_cooldown.is_stopped() and !attack_cooldown.is_paused():
		return false
	
	return true


func die() -> void:
	.die()
	velocity = Vector2.ZERO
	path = []
	set_state("Fall")
	set_behaviour_state("Dead")
	
	EVENTS.emit_signal("enemy_killed")



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_WaitTimer_timeout() -> void:
	if is_behaviour_state("Wander"):
		wander()


func _on_Bat_path_finished() -> void:
	if is_behaviour_state("Wander"):
		wanter_wait_timer.start(rand_range(min_wander_wait_time, max_wander_wait_time))


func _on_AggroArea_body_entered(body: Node) -> void:
	if body is Player && is_behaviour_state("Wander"):
		_chase(body)


func _on_ViewFieldArea_body_exited(body: Node) -> void:
	if body is Player:
		target = null
		wander()


func _on_ChasePathUpdateTimer_timeout() -> void:
	if is_behaviour_state("Chase"):
		_update_chase_path()


func _on_AttackDuration_timeout() -> void:
	_chase(target)


func _on_AttackArea_body_entered(body: Node) -> void:
	if body is Player && can_attack():
		_attack()


func _on_AttackCooldown_timeout() -> void:
	if can_attack():
		_attack()
