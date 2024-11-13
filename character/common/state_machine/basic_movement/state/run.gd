class_name Run
extends StateBase


var run_dust: Dust
var can_generate_dust: bool = false
var dust_wait_time: float
var is_creating_dust: bool = false
@export var run_dust_offset: Vector2


func enter() -> void:
	if state_machine.get("run_dust_offset"):
		run_dust_offset = state_machine.run_dust_offset
	target.animation_player.play("run")
	dust_wait_time = 0.5 if state_machine.history_state(1) == "Ground" else 0.1
	

func physics_update(delta: float) -> void:
	if target.stats.heart <= 0:
		transition_to("Died")
		return
	if target.is_hurt:
		transition_to("Hurt")
		return
	if not target.is_on_floor():
		transition_to("Fall")
		return
	if target.action_just_pressed_jump:
		transition_to("Jump")
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
	if target.action_get_axis == 0:
		transition_to("Idle")
		return
	can_generate_dust = true if state_machine.current_state_run_time > dust_wait_time else false
	if can_generate_dust and not is_creating_dust:
		is_creating_dust = true
		run_dust = DustCreator.generate(DustCreator.RUN_DUST, target.graphics, run_dust_offset)
	if not target.v_lock:
		target.velocity.x = target.action_get_axis * target.run_speed


func exit() -> void:
	if not target.v_lock:
		target.velocity.x = 0
	if is_creating_dust:
		if state_machine.next_state == "Jump":
			run_dust.queue_free()
		else:
			run_dust.free_deferred()
	can_generate_dust = false
	is_creating_dust = false
	
