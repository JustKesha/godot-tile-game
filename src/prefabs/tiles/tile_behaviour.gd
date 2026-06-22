@icon("uid://bs18cwna2f7b2")
class_name InteractiveTileBehaviour
extends Resource


@export_group("Process Delay", "delay")
@export var delay_activation_sec: float = 0.25
@export var delay_deactivation_sec: float = 0.0


func _activated(_tile: InteractiveTile): pass
func _deactivated(_tile: InteractiveTile): pass


static func process_action(tile: InteractiveTile, callback: Callable,
	delay_sec: float = 0.0):
	var process_token := tile.activation_count
	var process_state := tile.state
	
	if delay_sec > 0:
		await tile.get_tree().create_timer(delay_sec).timeout
	
	if( is_instance_valid(tile)
		and process_token == tile.activation_count
		and process_state == tile.state ):
		callback.call(tile)


func process_activation(tile: InteractiveTile):
	process_action(tile, _activated, delay_activation_sec)


func process_deactivation(tile: InteractiveTile):
	process_action(tile, _deactivated, delay_deactivation_sec)
