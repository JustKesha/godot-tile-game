@tool
@icon("uid://bdyesk6jthh6b")
class_name InteractiveTile
extends Node3D


signal activated(tile: InteractiveTile)
signal deactivated(tile: InteractiveTile)

enum State {
	IDLE,
	ACTIVE,
	}

const DEFAULT_VISUALS: InteractiveTileVisuals = preload("uid://blagnb7plmxp5")

@export var visuals: InteractiveTileVisuals:
	set(value):
		if visuals is InteractiveTileVisuals:
			if visuals.changed.is_connected(apply_visuals):
				visuals.changed.disconnect(apply_visuals)
		visuals = value
		if visuals is InteractiveTileVisuals:
			if not visuals.changed.is_connected(apply_visuals):
				visuals.changed.connect(apply_visuals)
		apply_visuals()
@export var behaviour: InteractiveTileBehaviour
@export var disabled: bool:
	set(value):
		disabled = value
		apply_visuals()
		_update_state()

var state: State = State.IDLE
var weight_applied: Stat
var activation_count: int

@onready var body: StaticBody3D = %Tile
@onready var mesh: MeshInstance3D = %Mesh
@onready var trigger: Area3D = %Trigger
@onready var collider: CollisionShape3D = %Collider
@onready var animation_player: AnimationPlayer = %Animator


func _ready():
	weight_applied = Stat.new(0, 0)
	weight_applied.value_changed.connect(_on_weight_applied_changed)
	apply_visuals()


func _on_trigger_body_entered(body_entered: Node3D):
	var rigid_body_entered := body_entered as RigidBody3D
	var weight := 1. if not rigid_body_entered else rigid_body_entered.mass
	weight_applied.add_modifier(
		StatModifier.new(
			str(body_entered.get_instance_id()),
			weight,
			)
	)


func _on_trigger_body_exited(body_entered: Node3D):
	weight_applied.remove_modifier(str(body_entered.get_instance_id()))


func _on_weight_applied_changed(_new_value: float):
	_update_state()


func _update_state():
	if not weight_applied:
		return
	
	if weight_applied.current_value > 0:
		activate()
	else:
		deactivate()


func activate():
	if disabled or state != State.IDLE:
		return
	
	state = State.ACTIVE
	activation_count += 1
	if behaviour:
		behaviour.process_activation(self)
	activated.emit(self)
	apply_visuals()
	animation_player.play("PRESS")


func deactivate():
	if disabled or state == State.IDLE:
		return
	
	state = State.IDLE
	if behaviour:
		behaviour.process_deactivation(self)
	deactivated.emit(self)
	apply_visuals()
	animation_player.play("RELEASE")


func apply_visuals(new_visuals: InteractiveTileVisuals = null):
	if disabled:
		new_visuals = DEFAULT_VISUALS
	if not new_visuals is InteractiveTileVisuals:
		new_visuals = visuals
	if not new_visuals is InteractiveTileVisuals:
		new_visuals = DEFAULT_VISUALS
	if not is_node_ready():
		apply_visuals.call_deferred(new_visuals)
		return
	
	var material = StandardMaterial3D.new()
	material.albedo_color = new_visuals.get_color(self)
	mesh.material_override = material
