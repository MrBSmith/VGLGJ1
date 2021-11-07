extends Actor
class_name Player

onready var dash_cooldown = $StatesMachine/Dash/Cooldown


const SPEED : float = 280.0
const JUMP_FORCE : float = 450.0
const WALL_GRAB_FALL_SPEED = 40.0
const DASH_SPEED = 700.0

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction : int = 0 setget set_direction 
var facing_direction : int = 0 setget set_facing_direction

var jump_buffered := false
var jump_tolerence := false
var wall_impulse := false setget set_wall_impulse

var max_nb_kunai := 4
var nb_kunai : int = max_nb_kunai setget set_nb_kunai

signal direction_changed
signal facing_direction_changed
signal wall_impulse_changed
signal touch_floor

#### ACCESSORS ####

func is_class(value: String): return value == "Player" or .is_class(value)
func get_class() -> String: return "Player"

func set_direction(value: int) -> void:
	if value!= direction:
		direction = value
		emit_signal("direction_changed")

func set_facing_direction(value: int) -> void: 
	if value != facing_direction:
		facing_direction = value
		emit_signal("facing_direction_changed")

func set_wall_impulse(value: bool) -> void:
	if value != wall_impulse:
		wall_impulse = value
		emit_signal("wall_impulse_changed")

func set_nb_kunai(value: int) -> void:
	if value != nb_kunai and value >= 0 and value <= max_nb_kunai:
		nb_kunai = value
		EVENTS.emit_signal("nb_kunai_changed", nb_kunai)


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("collect_kunai", self, "_on_EVENTS_collect_kunai")


func _physics_process(delta: float) -> void:
	if is_state("Hurt"):
		return
	
	if is_on_floor() && get_state_name() in ["Fall", "Jump"]:
		emit_signal("touch_floor")
	
	if is_state("Dash"):
		var collision = move_and_collide(velocity * delta)
		
		if collision != null:
			update_state()
	else:
		_compute_velocity()
		set_velocity(move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(1), false))
		
		if !is_state("Attack") && !is_state("Die"):
			update_state()


#### VIRTUALS ####



#### LOGIC ####


func update_state() -> void:
	if is_on_floor():
		set_wall_impulse(false)
		
		if jump_buffered:
			_jump()
		
		if direction == 0:
			set_state("Idle")
		else:
			set_state("Move")
	
	else:
		if is_on_wall() and !is_state("Jump"):
			var collision = get_slide_collision(0)
			var col_pos = collision.position
			var right_wall = col_pos.x > global_position.x
			
			if (Input.is_action_pressed("right") && right_wall) or \
			(Input.is_action_pressed("left") && !right_wall):
				set_state("WallGrab")
		
		else:
			if velocity.y > 0:
				set_state("Fall")


func _compute_velocity() -> void:
	var y_vel = WALL_GRAB_FALL_SPEED if get_state_name() == "WallGrab" else velocity.y + gravity
	set_velocity(Vector2(direction * SPEED, y_vel))


func trigger_jump_tolerence() -> void:
	jump_tolerence = true
	$JumpTolerenceTimer.start()


func buffer_jump() -> void:
	jump_buffered = true
	$JumpBufferTimer.start()


func _jump() -> void:
	set_state("Jump")
	jump_buffered = false
	
	var wall_dir = get_wall_direction()
	
	if wall_dir != 0 && !is_on_floor():
		set_direction(-wall_dir)
		wall_impulse = true
		$WallImpulseTimer.start()
	
	set_velocity(Vector2(velocity.x, velocity.y - JUMP_FORCE))


func _dash() -> void:
	var dir := Vector2.ZERO
	var mouse_pos = get_local_mouse_position()
	
	if is_on_floor() or is_state("Move"):
		if mouse_pos.x > 0:
			dir = Vector2.RIGHT
		else:
			dir = Vector2.LEFT
	else:
		dir = mouse_pos.normalized()
	
	set_facing_direction(int(sign(dir.x)))
	set_state("Dash")
	set_velocity(dir * DASH_SPEED)


func _attack() -> void:
	set_state("Attack")


func _throw_kunai() -> void:
	if nb_kunai <= 0:
		return
	
	var mouse_pos = get_local_mouse_position()
	set_nb_kunai(nb_kunai - 1)
	EVENTS.emit_signal("spawn_kunai", position, mouse_pos.normalized())


func is_near_wall() -> bool:
	for area in $WallDetection.get_children():
		for body in area.get_overlapping_bodies():
			if body is TileMap && body.name == "Walls":
				return true
	return false


func get_wall_direction() -> int:
	if !is_near_wall():
		return 0
	
	for body in $WallDetection/Left.get_overlapping_bodies():
		if body is TileMap and body.name == "Walls":
			return -1
	
	return 1


func _update_direction() -> void:
	set_direction(int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")))


func _is_dash_available() -> bool:
	return !is_state("Dash") and (dash_cooldown.is_stopped() or dash_cooldown.is_paused())


func die() -> void:
	set_state("Die")
	set_direction(0)



#### INPUTS ####

func _input(event: InputEvent) -> void:
	if is_state("Die"):
		return
	
	if !wall_impulse:
		_update_direction()
	
	if Input.is_action_just_pressed("jump"):
		if is_state("Fall"):
			buffer_jump()
		
		if is_on_floor() or is_near_wall() or jump_tolerence:
			_jump()
	
	elif Input.is_action_just_pressed("dash"):
		if _is_dash_available():
			_dash()
	
	elif event is InputEventMouseButton and Input.is_action_just_pressed("left_click"):
		_attack()
	
	elif event is InputEventMouseButton and Input.is_action_just_pressed("right_click"):
		_throw_kunai()


#### SIGNAL RESPONSES ####


func _on_JumpBufferTimer_timeout() -> void:
	jump_buffered = false


func _on_JumpTolerenceTimer_timeout() -> void:
	jump_tolerence = false


func _on_WallImpulseTimer_timeout() -> void:
	set_wall_impulse(false)


func _on_DashDuration_timeout() -> void:
	set_state("Idle")


func _on_StatesMachine_state_changing(from_state, to_state) -> void:
	if from_state == null or to_state == null:
		return
	
	if from_state.name in ["Idle", "Move"] and to_state.name == "Fall":
		trigger_jump_tolerence()


func _on_EVENTS_collect_kunai() -> void:
	set_nb_kunai(nb_kunai + 1)


func _on_Player_hp_changed() -> void:
	EVENTS.emit_signal("hp_changed", hp)


func _on_Player_direction_changed() -> void:
	if direction == 0:
		return
	else:
		set_facing_direction(direction)


func _on_Player_facing_direction_changed() -> void:
	$AnimatedSprite.set_flip_h(facing_direction == -1)


func _on_Player_touch_floor() -> void:
	set_wall_impulse(false)
	_update_direction()


func _on_Player_wall_impulse_changed() -> void:
	_update_direction()

