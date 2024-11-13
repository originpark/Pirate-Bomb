class_name PrimaryAction
extends StateBase


func enter() -> void:
	target.action_just_pressed_primary = false
	if (target.animation_player as AnimationPlayer).has_animation("attack"):
		target.animation_player.play("attack")
	target.primary_action(state_machine.get_message("target"))
	await (target.animation_player as AnimationPlayer).animation_finished
	transition_to("Idle")
