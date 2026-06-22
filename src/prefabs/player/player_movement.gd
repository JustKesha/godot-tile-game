@icon("uid://5x0jp48lvjw7")
class_name PlayerMovementController3D
extends Node


signal direction_changed(new_direction: Vector3)
signal velocity_changed(new_velocity: Vector3)

@export var body: CharacterBody3D
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var enabled: bool = true

@export_group("Walking")
@export var speed: float = 5.0
@export var acceleration: float = 45.0 
@export var deceleration: float = 35.0

@export_group("Jumping")
@export var jump_velocity: float = 4.5
@export var air_control: float = 1.0

@export_group("Controls", "controls")
@export var controls_forward: String = "ui_up"
@export var controls_backward: String = "ui_down"
@export var controls_left: String = "ui_left"
@export var controls_right: String = "ui_right"
@export var controls_jump: String = "ui_select"

@onready var velocity := Vector3.ZERO:
	set(value):
		if value.is_equal_approx(velocity):
			return
		velocity = value
		velocity_changed.emit(velocity)
@onready var is_grounded: bool:
	get():
		if not body: return false
		return body.is_on_floor()

var direction: Vector3:
	set(value):
		if value == direction:
			return
		direction = value
		direction_changed.emit(direction)


func _ready():
	if not body:
		body = get_parent() as CharacterBody3D
	if not body:
		push_error("Character body was not selected or found.")
		enabled = false


func _physics_process(delta: float):
	if not enabled:
		return
	update_velocity(delta)


func _input(event: InputEvent):
	if controls_jump and event.is_action_pressed(controls_jump) and is_grounded:
		return jump()
	
	direction = get_input_direction()


func _apply_gravity(delta: float = 0):
	if not delta: delta = get_process_delta_time()
	
	if is_grounded:
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta


func _apply_controls(delta: float = 0):
	if not delta: delta = get_process_delta_time()
	
	# Acceleration
	if direction:
		var strength := 1.0 if is_grounded else air_control
		
		velocity.x = move_toward(velocity.x,
			direction.x * speed * strength, acceleration * delta)
		velocity.z = move_toward(velocity.z,
			direction.z * speed * strength, acceleration * delta)
	
	# Deceleration
	else:
		velocity.x = move_toward(velocity.x, 0,
			deceleration * delta)
		velocity.z = move_toward(velocity.z, 0,
			deceleration * delta)


func get_input_direction() -> Vector3:
	var input_dir := Input.get_vector(controls_left, controls_right,
		controls_forward, controls_backward)
	
	return Vector3(input_dir.x, 0, input_dir.y).normalized()


func jump():
	velocity.y = jump_velocity


func update_velocity(delta: float):
	if not is_instance_valid(body):
		return
	
	_apply_gravity(delta)
	_apply_controls(delta)
