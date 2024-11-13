class_name Hurt
extends StateBase


func enter() -> void:
	target.is_hurt = false
	target.animation_player.play("hurt")
	target.v_lock = true
	await (target.animation_player as AnimationPlayer).animation_finished
	transition_to("Idle")
