class_name Fall
extends StateBase


const COYOTE_TIME: float = 0.1

var can_coyote_jump: bool = false

 
func enter() -> void:
	target.animation_player.play("fall")
	if state_machine.history_state(1) == "Run":
		can_coyote_jump = true
		get_tree().create_timer(COYOTE_TIME).timeout.connect(func (): can_coyote_jump = false)
	

func physics_update(delta: float) -> void:
	if target.stats.heart <= 0:
		transition_to("Died")
		return
	if target.is_hurt:
		transition_to("Hurt")
		return
	if target.is_on_floor():
		if state_machine.current_state_run_time > 0.3:
			transition_to("Ground")
			return
		else:
			transition_to("Idle")
			return
	if can_coyote_jump and target.action_just_pressed_jump:
		transition_to("Jump")
		return
	if not target.v_lock:
		target.velocity.x = target.action_get_axis * target.run_speed


func exit() -> void:
	if not target.v_lock:
		target.velocity.x = 0
