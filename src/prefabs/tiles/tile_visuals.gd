@tool
@icon("uid://dv3gp1kv5bvk0")
class_name InteractiveTileVisuals
extends Resource


@export var tint: Color = Color.WHITE:
	set(value):
		tint = value
		changed.emit()
@export var brightness: Dictionary[InteractiveTile.State, float] = {
	InteractiveTile.State.IDLE: 1.1,
	InteractiveTile.State.ACTIVE: 1.3,
	}:
	set(value):
		brightness = value
		changed.emit()


func get_brightness(tile: InteractiveTile) -> float:
	if brightness.has(tile.state):
		return brightness[tile.state]
	return tint.v


func get_color(tile: InteractiveTile) -> Color:
	var color := Color(tint)
	color.v = get_brightness(tile)
	return color
