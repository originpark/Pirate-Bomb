class_name BombTake
extends StateBase

var master

func enter() -> void:
	master = state_machine.get_message("master")


func physics_update(delta: float) -> void:
	if target.explotion:
		transition_to("BombExplotion")
		return
	if not target.is_take:
		if not target.is_off:
			transition_to("BombOn")
			return
	target.global_position = master.global_position + Vector2(-10, -20)
	if not target.is_off:
		target.modulate.r += 0.005
