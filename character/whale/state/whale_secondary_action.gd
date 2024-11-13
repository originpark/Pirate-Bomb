class_name WhaleSecondaryAction
extends StateBase


var bomb: Bomb

func enter() -> void:
	print("enter")
	target.action_just_pressed_secondary = false
	target.ai_state_machine.disable = true
	bomb = state_machine.get_message("target_bomb")
	if not bomb:
		transition_to("Idle")
		return
	var dir := 1 if target.global_position.x > bomb.global_position.x else -1
	target.animation_player.play("swalow")
	var bomb_pos := bomb.global_position
	bomb.linear_velocity = Vector2(dir * 60, -150)
	await target.animation_player.animation_finished
	if is_instance_valid(bomb):
		bomb.queue_free()


func physics_update(delta: float) -> void:
	if not bomb:
		target.ai_state_machine.disable = false
		transition_to("Idle")
		return 


func ani_callback() -> void:
	bomb.hide()
