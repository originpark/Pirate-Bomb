class_name BombGuySecondaryAction
extends StateBase


func enter() -> void:
	target.velocity.x = target.action_get_axis * target.run_speed


func physics_update(delta: float) -> void:
	transition_to("Idle")
