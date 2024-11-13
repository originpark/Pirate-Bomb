class_name AiIdle
extends StateBase


var stand_time: float
var move_time: float
var turn_around: bool


var timer: SceneTreeTimer
var can_move: bool = false


func enter() -> void:
	target.action_get_axis = 0
	stand_time = randf_range(state_machine.stand_time_min, state_machine.stand_time_max)
	move_time = randf_range(state_machine.move_time_min, state_machine.move_time_max)
	turn_around = true if randi_range(1, 10) <= state_machine.turn_around_percentage * 10 else false
	timer = get_tree().create_timer(stand_time)
	timer.timeout.connect(_on_timer_time_out)
	

func physics_update(delta: float) -> void:
	if (state_machine as AIStateMachine).wall_ray_cast.is_colliding():
		target.action_get_axis = target.direction.value * -1
	if not (state_machine as AIStateMachine).floor_ray_cast.is_colliding():
		#print("有悬崖")
		target.action_get_axis = 0
	if target.interact_body_list_bomb_sight or target.interact_body_character_sight:
		transition_to("AiTrack")
		return
	if state_machine.current_state_run_time - stand_time >= move_time:
		transition_to("AiIdle")
		return


func exit() -> void:
	timer.disconnect("timeout", _on_timer_time_out)
	timer = null
	target.action_get_axis = 0


func _on_timer_time_out() -> void:
	target.action_get_axis = target.direction.value * -1 if turn_around else target.direction.value
