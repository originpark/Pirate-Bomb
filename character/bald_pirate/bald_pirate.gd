class_name BaldPirate
extends CharacterBody2D


var action_lock: bool = true
var action_get_axis: int
var action_just_pressed_jump: bool
var action_just_pressed_primary: bool

var run_speed: float = 130.0
var jump_power: float = -500.0

@onready var direction: Direction = $Direction
@onready var control_able: ControlAble = $ControlAble
@onready var animation_player: AnimationPlayer = $Graphics/AnimationPlayer
@onready var graphics: Node2D = $Graphics


func _physics_process(delta: float) -> void:
	direction.value = action_get_axis
	move_and_slide()
