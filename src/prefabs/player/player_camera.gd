@icon("uid://drf4glas2n2o4")
class_name PlayerCameraController3D
extends Node3D


const MOUSE_MODE_ENABLED := Input.MOUSE_MODE_CAPTURED
const MOUSE_MODE_DISABLED := Input.MOUSE_MODE_VISIBLE
const MOUSE_SENSITIVITY_DIVIER: float = 100000

@export var body: CharacterBody3D
@export var camera_pivot: Node3D
@export_range(0,250) var mouse_sensitivity: float = 100
@export_range(-180,180) var v_min: float = -90
@export_range(-180,180) var v_max: float = 90
@export var enable_toggle_action: String = "ui_cancel"
@export var enabled: bool = true:
	set(value):
		enabled = value
		_update_cursor_state()


func _ready():
	if not camera_pivot:
		camera_pivot = self
	if not body:
		body = get_parent() as CharacterBody3D
	if not body:
		push_error("Character body was not selected or found.")
		enabled = false
		return
	_update_cursor_state()


func _update_cursor_state():
	Input.mouse_mode = MOUSE_MODE_ENABLED if enabled else MOUSE_MODE_DISABLED


func _rotate(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
	
	# Body (left/right)
	body.rotate_y(-event.relative.x * mouse_sensitivity/MOUSE_SENSITIVITY_DIVIER)
	# Neck (up/down)
	camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity/MOUSE_SENSITIVITY_DIVIER
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x,
		deg_to_rad(v_min), deg_to_rad(v_max))


func _unhandled_input(event: InputEvent):
	if enable_toggle_action and event.is_action_pressed(enable_toggle_action):
		enabled = !enabled
	
	if enabled:
		_rotate(event)
