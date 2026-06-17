@icon("uid://b822743d7v76o")
class_name StatVector3
extends Resource
## A 3D spatial vector container managing individual coordinate [Stat] engines.
##
## Synchronizes three independent numeric stats along the X, Y, and Z axes.
## Designed to compile composite spatial parameters (like velocity or scale) 
## using an isolated, multi-layered modification stack. Unassigned coordinate
## axes automatically fall back to a default [Stat] instance upon first access.

@export_category("Dimensions")
## The internal [Stat] tracking calculations for the horizontal X axis.
## Self-assigns a fresh [Stat] instance if [code]null[/code] on access.
@export var x: Stat:
	get():
		if not x: x = Stat.new()
		return x
## The internal [Stat] tracking calculations for the vertical Y axis.
## Self-assigns a fresh [Stat] instance if [code]null[/code] on access.
@export var y: Stat:
	get():
		if not y: y = Stat.new()
		return y
## The internal [Stat] tracking calculations for the depth Z axis.
## Self-assigns a fresh [Stat] instance if [code]null[/code] on access.
@export var z: Stat:
	get():
		if not z: z = Stat.new()
		return z

## The raw numeric baseline vectors across all coordinates before modifiers are processed.
var base_value: Vector3:
	get():
		return Vector3(x.base_value, y.base_value, z.base_value)
	set(value):
		x.base_value = value.x
		y.base_value = value.y
		z.base_value = value.z
## The final compiled and clamped 3D vector evaluation ready for engine physics utilization.
var current_value: Vector3:
	get():
		return Vector3(x.current_value, y.current_value, z.current_value)


func _init(p_x: Stat = null, p_y: Stat = null, p_z: Stat = null):
	x = p_x
	y = p_y
	z = p_z


## Sequentially routes isolated coordinate [StatModifier] capsules to their target axes.
## Pass [code]null[/code] to any argument to leave that specific coordinate axis untouched.
func add_modifiers(
	modifier_x: StatModifier,
	modifier_y: StatModifier,
	modifier_z: StatModifier ):
	if modifier_x: x.add_modifier(modifier_x)
	if modifier_y: y.add_modifier(modifier_y)
	if modifier_z: z.add_modifier(modifier_z)


## Applies a single [StatModifier] uniformly across all three spatial dimensions.
## Automatic internal duplication prevents lifecycle and timer synchronization conflicts.
func add_modifier(modifier: StatModifier):
	if not modifier: return
	x.add_modifier(modifier)
	y.add_modifier(modifier.duplicate())
	z.add_modifier(modifier.duplicate())


## Wipes an active modifier from [member x], [member y], and [member z]
## coordinate pipelines simultaneously using its [member StatModifier.id].
func remove_modifier(id: String):
	x.remove_modifier(id)
	y.remove_modifier(id)
	z.remove_modifier(id)


## Triggers a sweeping cleanup, stripping all active modifiers from all three coordinate dimensions.
func clear_modifiers():
	x.clear_modifiers()
	y.clear_modifiers()
	z.clear_modifiers()
