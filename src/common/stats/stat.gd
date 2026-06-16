@icon("uid://d2yyxsppbtc6v")
class_name Stat
extends Resource
## A customizable value tracking container managing modular modifiers.
##
## Compiles base values, local boundaries, and temporary status modifications 
## over time using lightweight system Tweens to bypass node architecture overhead.

## Emitted when the computed [member current_value] changes.
signal value_changed(new_value: float)

@export_category("Base Config")
## The structural numeric baseline before modification arithmetic is processed.
@export var base_value: float = 0.0:
	set(value):
		base_value = value
		if _is_ready:
			calculate()
## The absolute minimum value clamp boundary limit.
@export var min_value: float = -INF:
	set(value):
		min_value = value
		if _is_ready:
			calculate()
## The absolute maximum value clamp boundary limit.
@export var max_value: float = INF:
	set(value):
		max_value = value
		if _is_ready:
			calculate()

@export_group("Other")
## The list of modifier which will be added once the [Stat] is ready.
@export var start_modifiers: Array[StatModifier] = []
## The exact step-by-step sequence in which the modifier operations are executed.
@export var operation_order: Array[StatModifier.Operation] = [
		StatModifier.Operation.ADD,
		StatModifier.Operation.MULTIPLY,
	]:
	set(value):
		operation_order = value
		if _is_ready:
			calculate()

var _modifiers: Dictionary[String, StatModifier] = {}
var _tweens: Dictionary[String, Tween] = {}
var _is_ready: bool = false

## The consolidated calculation result clamped safely between limits.
var current_value: float = 0.0
## Used to host modifier duration tweens, should be set to the node holding the [Stat].
## By default tweens are hosted on [code]Engine.get_main_loop()[/code].
var host: Node = StatManager


func _init(p_base: float = 0.0, p_min: float = -INF, p_max: float = INF,
	p_start_modifiers: Array[StatModifier] = [],
	p_operation_order: Array[StatModifier.Operation] = [
		StatModifier.Operation.ADD,
		StatModifier.Operation.MULTIPLY,
	]):
	base_value = p_base
	min_value = p_min
	max_value = p_max
	start_modifiers = p_start_modifiers
	operation_order = p_operation_order
	_ready.call_deferred()


func _ready():
	var start_modifiers_applied := false
	for mod in start_modifiers:
		if _is_modifier_valid(mod):
			add_modifier(mod)
			start_modifiers_applied = true
	
	if not start_modifiers_applied:
		calculate()
	
	_is_ready = true


func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		for tween in _tweens.values():
			if is_instance_valid(tween):
				tween.kill()


func _is_modifier_valid(modifier: StatModifier) -> bool:
	return modifier and not modifier.id.is_empty()


func _create_duration_tween(modifier: StatModifier):
	if _tweens.has(modifier.id):
		var existing_tween = _tweens[modifier.id]
		if is_instance_valid(existing_tween):
			existing_tween.kill()
	
	var tween_host: Node = host
	if not tween_host:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.current_scene:
			tween_host = tree.current_scene
	
	if not tween_host or not tween_host.is_inside_tree():
		push_error("Cannot create modifier duration tween without a valid host node.")
		return
	
	var new_tween = tween_host.create_tween()
	_tweens[modifier.id] = new_tween
	new_tween.tween_interval(modifier.duration)
	new_tween.tween_callback(func(): remove_modifier(modifier.id))


## Registers a [StatModifier] reference and processes the math stack. If the
## modifier is temporary, it bounds a dynamic Tween to the [member host]. If
## [member host] is null, will try to use the [code]Engine.get_main_loop()[/code].
func add_modifier(modifier: StatModifier):
	if not _is_modifier_valid(modifier): return
	
	_modifiers[modifier.id] = modifier
	calculate()
	
	if modifier.is_temporary():
		_create_duration_tween(modifier)


## Wipes a modifier entry using its [param id] and cancels the associated Tween track.
func remove_modifier(id: String):
	if _tweens.has(id):
		var tween = _tweens[id]
		if is_instance_valid(tween):
			tween.kill()
		_tweens.erase(id)
	
	if _modifiers.erase(id):
		calculate()


## Removes all modifier from the [Stat].
func clear_modifiers():
	for mod_id in _modifiers.keys():
		remove_modifier(mod_id)


## Evaluates the active additive and multiplicative rules against the base data layer.
## Normalizes the final results inside specified property boundaries.
func calculate() -> float:
	var tally: float = base_value
	
	var grouped_modifiers: Dictionary[StatModifier.Operation, Array] = {}
	for op in operation_order:
		grouped_modifiers[op] = []
	
	for mod in _modifiers.values():
		if grouped_modifiers.has(mod.operation):
			grouped_modifiers[mod.operation].append(mod.value)
	
	for op in operation_order:
		var values: Array = grouped_modifiers[op]
		
		match op:
			StatModifier.Operation.ADD:
				for val in values:
					tally += val
			StatModifier.Operation.MULTIPLY:
				for val in values:
					tally *= val
	
	var old_value = current_value
	current_value = clamp(tally, min_value, max_value)
	
	if not is_equal_approx(old_value, current_value):
		value_changed.emit(current_value)
	
	return current_value
