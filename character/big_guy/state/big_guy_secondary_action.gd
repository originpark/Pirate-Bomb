class_name BigGuySecondaryAction
extends StateBase


func enter() -> void:
	target.action_just_pressed_secondary = false
	var bomb: Bomb = state_machine.get_message("target_bomb") 
	target.animation_player.play("pick_bomb")
	target.can_attack = false
	get_tree().create_timer(target.attack_reload_time).timeout.connect(func(): target.can_attack = true)
	await (target.animation_player as AnimationPlayer).animation_finished
	if not is_instance_valid(bomb):
		transition_to("Idle")
		return
	(bomb.state_machine as StateMachine).set_message("master", target)
	bomb.is_take = true
	target.ai_state_machine.disable = true
	transition_to("BigGuyIdleWithBomb")
