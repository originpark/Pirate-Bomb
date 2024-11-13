class_name CucumberPrimaryAction
extends StateBase


func enter() -> void:
	target.action_just_pressed_primary = false
	target.animation_player.play("attack")
	var obj := state_machine.get_message("target_character") 
	var dir = target.direction.value
	target.can_attack = false
	get_tree().create_timer(target.attack_reload_time).timeout.connect(func(): target.can_attack = true)
	Effect.physics_attack(target.stats, obj.stats)
	await (target.animation_player as AnimationPlayer).animation_finished
	transition_to("Idle")
