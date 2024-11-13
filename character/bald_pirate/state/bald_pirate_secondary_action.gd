class_name BaldPirateSecondaryAction
extends StateBase


func enter() -> void:
	target.action_just_pressed_secondary = false
	target.animation_player.play("attack")
	var obj := state_machine.get_message("target_bomb") 
	var dir = target.direction.value
	if obj is Bomb:
		obj.linear_velocity = Vector2(500 * dir, -300)
	target.can_attack = false
	get_tree().create_timer(target.attack_reload_time).timeout.connect(func(): target.can_attack = true)
	await (target.animation_player as AnimationPlayer).animation_finished
	transition_to("Idle")
