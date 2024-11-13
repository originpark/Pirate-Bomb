class_name Died
extends StateBase


func enter() -> void:
	target.animation_player.play("died")
	target.died()
	
