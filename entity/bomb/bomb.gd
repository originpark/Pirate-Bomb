class_name Bomb
extends RigidBody2D



var interact_body_list_explotion_area: Array

var explotion: bool = false
var time: float = 0
var is_off: bool = false
var is_take: bool = false

@onready var animation_player: AnimationPlayer = $Graphics/AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var stats: Stats = $Stats


func _physics_process(delta: float) -> void:
	if state_machine.current_state.name == "BombOff":
		return
	time += delta
	if time >= 3:
		explotion = true


func is_on_floor() -> bool:
	return (abs(linear_velocity.y) as int) == 0
