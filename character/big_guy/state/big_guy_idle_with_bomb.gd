class_name BigGuyIdleWithBomb
extends StateBase


func enter() -> void:
	target.animation_player.play("idle_bomb")
	var bomb: Bomb = state_machine.get_message("target_bomb")
	transition_to("BigGuyThrowBomb")
	return
	
