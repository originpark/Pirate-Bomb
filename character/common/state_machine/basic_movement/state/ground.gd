class_name Ground
extends StateBase


func enter() -> void:
	target.animation_player.play("ground")
	DustCreator.generate(DustCreator.FALL_DUST, get_tree().current_scene, target.global_position).free_deferred()
	await  target.animation_player.animation_finished
	transition_to("Idle")
