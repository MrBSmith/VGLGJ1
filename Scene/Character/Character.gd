extends KinematicBody2D
class_name Character

const SPEED : float = 280.0
const GRAVITY : float = 20.0
const JUMP_FORCE : float = 450.0

var direction : int = 0 setget set_direction 
var velocity := Vector2.ZERO setget set_velocity

var jump_buffered := false
var jump_tolerence := false

signal direction_changed

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


#### BUILT-IN ####

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	var grav = GRAVITY / 6 if get_state_name() == "WallGrab" else GRAVITY
	
	set_velocity(Vector2(direction * SPEED, velocity.y + grav))
	set_velocity(move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(1), false))
	
	if is_on_floor():
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



#### VIRTUALS ####



#### LOGIC ####


func trigger_jump_tolerence() -> void:
	jump_tolerence = true
	$JumpTolerenceTimer.start()

func buffer_jump() -> void:
	jump_buffered = true
	$JumpBufferTimer.start()


func _jump() -> void:
	set_state("Jump")
	jump_buffered = false
	
	set_velocity(velocity + (Vector2.UP * JUMP_FORCE))


#### INPUTS ####

func _input(_event: InputEvent) -> void:
	set_direction(int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")))
	
	if Input.is_action_just_pressed("jump"):
		if is_state("Fall"):
			buffer_jump()
		
		if is_on_floor() or is_state("WallGrab") or jump_tolerence:
			_jump()


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
