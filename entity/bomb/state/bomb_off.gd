class_name BombOff
extends StateBase


func enter() -> void:
	target.animation_player.play("off")
	target.modulate.r = 1


func physics_update(delta: float) -> void:
	if target.is_take:
		transition_to("BombTake")
