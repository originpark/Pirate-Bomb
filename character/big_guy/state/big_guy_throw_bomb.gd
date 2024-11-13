class_name BigGuyThrowBomb
extends StateBase


func enter() -> void:
	var bomb: Bomb = state_machine.get_message("target_bomb")
	var player := get_tree().get_nodes_in_group("player")
	if player:
		target.direction.value = 1 if player[0].global_position.x > target.global_position.x else -1
	target.animation_player.play("throw_bomb")
	await get_tree().create_timer(0.1).timeout
	bomb.linear_velocity = Vector2(target.direction.value * 400, -600)
	bomb.is_take = false
	await target.animation_player.animation_finished
	target.ai_state_machine.disable = false
	transition_to("Idle")
