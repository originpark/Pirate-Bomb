class_name Idle
extends StateBase


func enter() -> void:
	target.animation_player.play("idle")


func physics_update(delta: float) -> void:
	if target.stats.heart <= 0:
		transition_to("Died")
		return
	if target.is_hurt:
		transition_to("Hurt")
		return
	if not target.is_on_floor():
		transition_to("Fall")
		return
	if target.action_just_pressed_jump:
		transition_to("Jump")
		return
	if target.action_just_pressed_primary:
		if target.can_attack:
			transition_to(target.to_string() + "PrimaryAction")
			return
		else:
			target.action_just_pressed_primary = false
	if target.action_just_pressed_secondary:
		if target.can_attack:
			transition_to(target.to_string() + "SecondaryAction")
			return
		else:
			target.action_just_pressed_secondary = false
	if target.action_get_axis != 0:
		transition_to("Run")
		return
