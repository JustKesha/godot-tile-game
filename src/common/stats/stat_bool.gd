@icon("uid://dyxypaetfvkmi")
class_name StatBool
extends Stat
## A logical state container backed by a math-driven [Stat] engine.
##
## Tracks a boolean state as a cumulative weight tally to prevent race conditions 
## from overlapping status effects or logical locks.


## Returns [code]true[/code] if the cumulative modifier weight is greater than zero.
var current_bool: bool:
	get():
		return current_value > 0.0


func _get_node_lock_id(node: Node) -> String:
	if not is_instance_valid(node):
		return ""
	return str(node.get_instance_id())


func _is_node_connected(node: Node, id: String) -> bool:
	if not is_instance_valid(node):
		return false
	for connection in node.tree_exited.get_connections():
		var callable: Callable = connection["callable"]
		if callable.get_object() == self and callable.get_bound_arguments().has(id):
			return true
	return false


## Injects a generic state lock modifier ([code]+1.0[/code]) into the calculation pool.
## Use [method remove_lock] for lock removal.
## [br][br]Syntax sugar for [method Stat.add_modifier].
func add_lock(id: String, duration: float = 0.0):
	add_modifier(StatModifier.new(id, 1.0, duration, StatModifier.Operation.ADD))


## Removes a specific state lock modifier from the calculation pool by [param id].
##[br][br] Syntax sugar for [method Stat.remove_modifier].
func remove_lock(id: String):
	remove_modifier(id)


## Binds a state lock modifier ([code]+1.0[/code]) to a specific [Node]'s lifecycle.
## Automatically strips the lock via [signal Node.tree_exited] if the node is deleted.
func add_node_lock(node: Node, duration: float = 0.0):
	var id := _get_node_lock_id(node)
	if not id:
		return
	
	add_lock(id, duration)
	
	if not _is_node_connected(node, id):
		node.tree_exited.connect(remove_modifier.bind(id), CONNECT_ONE_SHOT)


## Manually strips a node-bound lock and safely cleans up its lifecycle signal.
func remove_node_lock(node: Node):
	var id := _get_node_lock_id(node)
	if not id:
		return
	
	remove_modifier(id)
	
	if is_instance_valid(node):
		for connection in node.tree_exited.get_connections():
			var callable: Callable = connection["callable"]
			if callable.get_object() == self and callable.get_bound_arguments().has(id):
				node.tree_exited.disconnect(callable)
				break
