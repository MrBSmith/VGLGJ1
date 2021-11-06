extends KinematicBody2D
class_name Player

onready var dash_cooldown = $StatesMachine/Dash/Cooldown

const SPEED : float = 280.0
const JUMP_FORCE : float = 450.0
const WALL_GRAB_FALL_SPEED = 40.0
const DASH_SPEED = 700.0

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction : int = 0 setget set_direction 
var velocity := Vector2.ZERO setget set_velocity

var jump_buffered := false
var jump_tolerence := false
var wall_impulse := false setget set_wall_impulse

signal direction_changed
signal wall_impulse_changed

#### ACCESSORS ####

func is_class(value: String): return value == "Character" or .is_class(value)
func get_class() -> String: return "Character"

func set_direction(value: int) -> void:
	if value!= direction:
		direction = value
		emit_signal("direction_changed")

func set_state(state_name: String) -> void:
	$StatesMachine.set_state(state_name)
func get_state() -> StateBase: return $StatesMachine.get_state()
func get_state_name() -> String: return $StatesMachine.get_state_name()
func is_state(value: String) -> bool: return get_state_name() == value

func set_velocity(value: Vector2) -> void: velocity = value

func set_wall_impulse(value: bool) -> void:
	if value != wall_impulse:
		wall_impulse = value
		emit_signal("wall_impulse_changed")

#### BUILT-IN ####

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if !is_state("Dash"):
		update_state()
		_compute_velocity()

	set_velocity(move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(1), false))


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
		if is_on_wall() && !is_state("Jump"):
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
	if wall_dir != 0:
		direction = -wall_dir
		wall_impulse = true
		$WallImpulseTimer.start()
	
	set_velocity(Vector2(velocity.x, velocity.y - JUMP_FORCE))


func _dash() -> void:
	set_state("Dash")
	
	set_velocity(Vector2(direction * DASH_SPEED, 0))


func _attack() -> void:
	set_state("Attack")


func _throw_kunai() -> void:
	var mouse_pos = get_local_mouse_position()
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
	return dash_cooldown.is_stopped() or dash_cooldown.is_paused()


#### INPUTS ####

func _input(event: InputEvent) -> void:
	if !wall_impulse:
		_update_direction()
	
	if Input.is_action_just_pressed("jump"):
		if is_state("Fall"):
			buffer_jump()
		
		if is_on_floor() or is_near_wall() or jump_tolerence:
			_jump()
	
	elif Input.is_action_just_pressed("dash"):
		if _is_dash_available() && direction != 0:
			_dash()
	
	elif event is InputEventMouseButton and Input.is_action_just_pressed("left_click"):
		_attack()
	
	elif event is InputEventMouseButton and Input.is_action_just_pressed("right_click"):
		_throw_kunai()

#### SIGNAL RESPONSES ####


func _on_Character_direction_changed() -> void:
	if direction == 0:
		set_state("Idle")
	else:
		set_state("Move")


func _on_JumpBufferTimer_timeout() -> void:
	jump_buffered = false


func _on_JumpTolerenceTimer_timeout() -> void:
	jump_tolerence = false


func _on_WallImpulseTimer_timeout() -> void:
	wall_impulse = false


func _on_Character_wall_impulse_changed() -> void:
	if wall_impulse == false:
		_update_direction()


func _on_DashDuration_timeout() -> void:
	update_state()

