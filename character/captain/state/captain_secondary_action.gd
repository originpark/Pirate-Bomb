class_name CaptainSecondaryAction
extends StateBase


var run_dust_offset: Vector2
var run_dust: Dust
var can_generate_dust: bool = false
var dust_wait_time: float
var is_creating_dust: bool = false
var can_turn_back: bool = true


func enter() -> void:
	target.action_just_pressed_secondary = false
	var bomb: Bomb = state_machine.get_message("target_bomb")
	if not is_instance_valid(bomb):
		transition_to("Idle")
		return
	var scare_run_dir := 1 if bomb.global_position.x <= target.global_position.x else -1
	target.animation_player.play("scare_run")
	target.action_get_axis = scare_run_dir
	if not target.v_lock:
		target.velocity.x = target.action_get_axis * target.run_speed
	if state_machine.get("run_dust_offset"):
		run_dust_offset = state_machine.run_dust_offset
	target.ai_state_machine.disable = true


func physics_update(delta: float) -> void:
	if (target.interact_body_list_bomb_sight as Array).size() == 0:
		transition_to("Idle")
		return
	var bomb_list: Array[Bomb] = target.interact_body_list_bomb_sight
	var nearest_bomb: Bomb
	var min_distance := 65535.0
	for bomb in bomb_list:
		if bomb.is_off and target is not BigGuy:
			continue
		var distance := (bomb as Bomb).global_position.distance_to(target.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_bomb = bomb
	if can_turn_back:
		target.action_get_axis = 1 if nearest_bomb.global_position.x < target.global_position.x else -1
		can_turn_back = false
		get_tree().create_timer(0.3).timeout.connect(func (): can_turn_back = true)
	if not target.v_lock:
		target.velocity.x = target.action_get_axis * target.run_speed
	can_generate_dust = true if state_machine.current_state_run_time > dust_wait_time else false
	if can_generate_dust and not is_creating_dust:
		is_creating_dust = true
		run_dust = DustCreator.generate(DustCreator.RUN_DUST, target.graphics, run_dust_offset)


func exit() -> void:
	if not target.v_lock:
		target.velocity.x = 0
		target.action_get_axis = 0
	if is_creating_dust:
		if state_machine.next_state == "Jump":
			run_dust.queue_free()
		else:
			run_dust.free_deferred()
	can_generate_dust = false
	is_creating_dust = false
	target.ai_state_machine.disable = false
