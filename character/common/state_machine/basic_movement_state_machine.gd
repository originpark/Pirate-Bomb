class_name BasicMovementStateMachine
extends StateMachine


@export var run_dust_offset: Vector2

var basic_state: Dictionary = {
	Fall = preload("res://character/common/state/fall.gd"),
	Ground = preload("res://character/common/state/ground.gd"),
	Idle = preload("res://character/common/state/idle.gd"),
	Jump = preload("res://character/common/state/jump.gd"),
	Run = preload("res://character/common/state/run.gd")
}


func _before_load() -> void:
	for state in basic_state:
		var state_instancs = basic_state[state].new()
		state_instancs.name = state
		add_child(state_instancs)


func _before_start() -> void:
	initial_state = _states["Idle"]
