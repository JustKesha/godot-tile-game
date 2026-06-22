class_name Player
extends CharacterBody3D


@export_group("Physics")
@export var rigid_body_push_force: float = 10.0

@export_group("Stats", "stat")
@export var stat_velocity: StatVector3:
	get():
		if not stat_velocity: stat_velocity = StatVector3.new()
		return stat_velocity

@onready var movement_controller: PlayerMovementController3D = %Movement
@onready var camera_controller: PlayerCameraController3D = %Tripod


func _physics_process(_delta: float):
	_move()
	_push_rigid_bodies()


func _move():
	_apply_velocity()
	velocity = stat_velocity.current_value
	move_and_slide()


func _apply_velocity():
	var local_velocity := movement_controller.velocity
	
	if local_velocity.is_zero_approx():
		stat_velocity.remove_modifier("movement_controller")
		return
	
	var global_horizontal := transform.basis * Vector3(local_velocity.x, 0, local_velocity.z)
	
	stat_velocity.add_modifiers(
		StatModifier.new("movement_controller", global_horizontal.x),
		StatModifier.new("movement_controller", local_velocity.y),
		StatModifier.new("movement_controller", global_horizontal.z),
		)


func _push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var rigid_body := collider as RigidBody3D
		
		if not rigid_body or collider.freeze:
			return
		
		var direction := -collision.get_normal()
		var current_speed := Vector3(velocity.x, 0, velocity.z).length()
		var local_force_position = collision.get_position() - rigid_body.global_position
		var final_impulse := direction * current_speed * rigid_body_push_force
		
		rigid_body.apply_impulse(final_impulse, local_force_position)


func _on_movement_velocity_changed(_local_velocity: Vector3):
	_apply_velocity()


func apply_impulse(impulse: Vector3):
	movement_controller.velocity += impulse
