class_name EnemyCommon
extends CharacterBody2D


# 输入映射
var action_lock: bool = true
var action_get_axis: int
var action_just_pressed_jump: bool
var action_just_pressed_primary: bool
var action_just_pressed_secondary: bool


# area映射
var interact_body_character_sight: CharacterBody2D
var interact_body_list_bomb_sight: Array[Bomb]

# 角色属性
var run_speed: float = 150.0
var jump_power: float = -500.0
var attack_reload_time: float = 1

# 组件引用
@onready var direction: Direction = $Direction
@onready var control_able: ControlAble = $ControlAble
@onready var animation_player: AnimationPlayer = $Graphics/AnimationPlayer
@onready var graphics: Node2D = $Graphics
@onready var gravity: Gravity = $Gravity
@onready var ai_state_machine: AIStateMachine = $AIStateMachine
@onready var basic_state_machine: BasicStateMachine = $BasicStateMachine
@onready var stats: Stats = $Stats
@onready var decelerate: Decelerate = $Decelerate


# 逻辑工具
var can_attack: bool = true
var v_lock: bool = false
var is_hurt: bool = false
var is_died: bool = false


func _physics_process(delta: float) -> void:
	direction.value = action_get_axis
	update_interact_bomb_list()
	move_and_slide()


func update_interact_bomb_list() -> void:
	interact_body_list_bomb_sight = interact_body_list_bomb_sight.filter(func(bomb): return is_instance_valid(bomb))


func _to_string() -> String:
	return name


func died() -> void:
	action_get_axis = 0
	v_lock = true
	action_lock = true
	is_died = true
