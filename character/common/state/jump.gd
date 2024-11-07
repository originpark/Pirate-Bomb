class_name Jump
extends StateBase


func enter() -> void:
	target.animation_player.play("jump")
	target.velocity.y = target.jump_power
	DustCreator.generate(DustCreator.JUMP_DUST, get_tree().current_scene, target.global_position).free_deferred()


func physics_update(delta: float) -> void:
	if target.is_on_floor():
		transition_to("Idle")
		return
	if target.velocity.y > 0:
		transition_to("Fall")
		return
	target.velocity.x = target.action_get_axis * target.run_speed


func exit() -> void:
	target.velocity.x = 0
