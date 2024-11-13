class_name Jump
extends StateBase


func enter() -> void:
	target.animation_player.play("jump")
	target.velocity.y = target.jump_power
	DustCreator.generate(DustCreator.JUMP_DUST, get_tree().current_scene, target.global_position).free_deferred()


func physics_update(delta: float) -> void:
	if target.stats.heart <= 0:
		transition_to("Died")
		return
	if target.is_hurt:
		transition_to("Hurt")
		return
	if target.is_on_floor():
		transition_to("Idle")
		return
	if target.velocity.y > 0:
		transition_to("Fall")
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
	if not target.v_lock:
		target.velocity.x = target.action_get_axis * target.run_speed


func exit() -> void:
	if not target.v_lock:
		target.velocity.x = 0
