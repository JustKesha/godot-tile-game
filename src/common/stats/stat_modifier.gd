@icon("uid://bgff01ooebpe4")
class_name StatModifier
extends Resource
## An isolated value modification capsule for a [Stat].
##
## Stored data instructions representing a single mathematical change. 
## Used in conjunction with a [Stat] object to alter parameters dynamically.

## Defines the mathematical rules used when evaluating the modifier strength.
enum Operation {
	## Adds the value directly to the stat's running calculation pool.
	ADD, 
	## Multiplies the running total of the stat calculation pool.
	MULTIPLY,
	}

## The unique lookup string key identifying this modifier.
@export var id: String = "default_id"
## The numerical power applied during mathematical evaluation.
@export var value: float = 1.0
## The modification category rule mapping.
@export var operation: Operation = Operation.ADD
## The active lifespan of the modifier in seconds.
##
## If set to a value greater than [code]0.0[/code], the modifier is treated as
## temporary and will automatically be discarded via an internal clock sequence. 
## If set to [code]0.0[/code] or a negative value, the modifier behaves as a permanent effect.
@export var duration: float = 0.0


func _init(
		p_id: String = "default_id",
		p_value: float = 1.0,
		p_duration: float = 0.0,
		p_op: Operation = Operation.ADD,
	):
	id = p_id
	value = p_value
	duration = p_duration
	operation = p_op


## Returns [code]true[/code] if the modifier relies on a countdown timer to expire.
func is_temporary() -> bool:
	return duration > 0.0
