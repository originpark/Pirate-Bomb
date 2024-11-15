class_name BombGuyPrimaryAction
extends StateBase

func enter() -> void:
	target.velocity.x = target.action_get_axis * target.run_speed

func physics_update(delta: float) -> void:
	if state_machine.history_state(1) == "Idle":
		transition_to("Idle")
	elif state_machine.history_state(1) == "Run":
		transition_to("Run")
	elif state_machine.history_state(1) == "Jump":
		transition_to("Fall")
	elif state_machine.history_state(1) == "Fall":
		transition_to("Fall")
	
