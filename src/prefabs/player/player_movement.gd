@icon("uid://5x0jp48lvjw7")
class_name PlayerMovementController3D
extends Node


signal internal_velocity_changed(new_internal_velocity: Vector3)

@export var body: CharacterBody3D
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var enabled: bool = true

@export_group("Walking")
@export var speed: float = 5.0
@export var acceleration: float = 45.0 
@export var deceleration: float = 35.0

@export_group("Jumping", "jump")
@export var jump_velocity: float = 4.5
# @export var jump_air_control: float = 1.0

@export_group("Controls", "controls")
@export var controls_forward: String = "ui_up"
@export var controls_backward: String = "ui_down"
@export var controls_left: String = "ui_left"
@export var controls_right: String = "ui_right"
@export var controls_jump: String = "ui_select"

@onready var internal_velocity := Vector3.ZERO:
	set(value):
		if value.is_equal_approx(internal_velocity):
			return
		internal_velocity = value
		internal_velocity_changed.emit(internal_velocity)
@onready var is_grounded: bool:
	get():
		if not body: return false
		return body.is_on_floor()


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


func _get_new_internal_velocity(delta: float) -> Vector3:
	var new_internal_velocity := internal_velocity
	
	# 1. Гравитация
	if is_grounded:
		new_internal_velocity.y = 0.0
	else:
		new_internal_velocity.y -= gravity * delta
	
	# 2. Прыжок
	if controls_jump and Input.is_action_just_pressed(controls_jump) and is_grounded:
		new_internal_velocity.y = jump_velocity
	
	# 3. Сбор вектора ввода
	var input_dir := Input.get_vector(controls_left, controls_right,
		controls_forward, controls_backward)
	
	# 4. Чистый локальный вектор направления (как у тебя и было!)
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# 5. Плавный разгон и торможение в локальном пространстве
	if direction:
		new_internal_velocity.x = move_toward(new_internal_velocity.x,
			direction.x * speed, acceleration * delta)
		new_internal_velocity.z = move_toward(new_internal_velocity.z,
			direction.z * speed, acceleration * delta)
	else:
		new_internal_velocity.x = move_toward(new_internal_velocity.x, 0,
			deceleration * delta)
		new_internal_velocity.z = move_toward(new_internal_velocity.z, 0,
			deceleration * delta)
	
	return new_internal_velocity


func update_velocity(delta: float):
	if not is_instance_valid(body):
		return
	
	internal_velocity = _get_new_internal_velocity(delta)
