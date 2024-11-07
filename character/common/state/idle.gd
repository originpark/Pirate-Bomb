class_name Idle
extends StateBase


func enter() -> void:
	target.animation_player.play("idle")


func physics_update(delta: float) -> void:
	if not target.is_on_floor():
		transition_to("Fall")
		return
	if target.action_just_pressed_jump:
		transition_to("Jump")
		return
	if target.action_get_axis != 0:
		transition_to("Run")
		return
