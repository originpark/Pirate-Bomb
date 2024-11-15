class_name CucumberSecondaryAction
extends StateBase


func enter() -> void:
	target.action_just_pressed_secondary = false
	target.ai_state_machine.disable = true
	var bomb: Bomb = state_machine.get_message("target_bomb") 
	target.direction.value = 1 if bomb.global_position.x > target.global_position.x else -1
	target.animation_player.play("blow")
	target.can_attack = false
	get_tree().create_timer(target.attack_reload_time).timeout.connect(func(): target.can_attack = true)
	await (target.animation_player as AnimationPlayer).animation_finished
	if is_instance_valid(bomb):
		bomb.is_off = true
	target.ai_state_machine.disable = false
	transition_to("Idle")
