class_name CucumberSecondaryAction
extends StateBase


func enter() -> void:
	target.action_just_pressed_secondary = false
	target.animation_player.play("blow")
	var bomb: Bomb = state_machine.get_message("target_bomb") 
	target.can_attack = false
	get_tree().create_timer(target.attack_reload_time).timeout.connect(func(): target.can_attack = true)
	await (target.animation_player as AnimationPlayer).animation_finished
	bomb.is_off = true
	transition_to("Idle")