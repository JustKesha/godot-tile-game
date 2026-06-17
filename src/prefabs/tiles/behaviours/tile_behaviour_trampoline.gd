class_name InteractiveTileBehaviourTrampoline
extends InteractiveTileBehaviour


@export var impulse: Vector3 = Vector3.UP * 6


func _activated(tile: InteractiveTile):
	for body in tile.trigger.get_overlapping_bodies():
		if not is_instance_valid(body):
			continue
		
		var rigid_body := body as RigidBody3D
		if rigid_body:
			rigid_body.apply_impulse(impulse)
			continue
		
		var player := body as Player
		if player:
			# NOTE Using player's custom apply_impulse would not reset velocity
			# player.apply_impulse(impulse)
			player.movement_controller.internal_velocity = impulse
			continue
