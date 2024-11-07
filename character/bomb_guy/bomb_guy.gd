class_name BombGuy
extends CharacterBody2D

const BOMB = preload("res://entity/bomb/bomb.tscn")

# 玩家输入检测
var action_get_axis: int
var action_just_pressed_jump: bool
var action_pressed_primary: bool
var action_just_pressed_primary: bool
var action_just_released_primary: bool

# 角色属性
var run_speed: float = 150.0
var jump_power: float = -500.0

# 投掷炸弹相关的数值
var max_throw_power_x: float = 500.0
var max_throw_power_y: float = -250.0
var max_accumulate_time: float = 1.0
var current_accumulate_time: float = 0.0

# 子节点引用
@onready var animation_player: AnimationPlayer = $Graphics/AnimationPlayer
@onready var direction: Direction = $Direction
@onready var graphics: Node2D = $Graphics
@onready var energy_bar: EnergyBar = $EnergyBar


func _ready() -> void:
	energy_bar.hide()


func _physics_process(delta: float) -> void:
	direction.value = action_get_axis
	throw_bomb(delta)
	move_and_slide()


func throw_bomb(delta: float) -> void:
	if action_pressed_primary:
		current_accumulate_time += delta
		if current_accumulate_time > 0.1:
			energy_bar.show()
			energy_bar.texture_progress_bar.value = current_accumulate_time / max_accumulate_time
	if action_just_released_primary:
		var bomb := BOMB.instantiate()
		get_tree().current_scene.add_child(bomb)
		bomb.global_position = Vector2(global_position.x, global_position.y - 10)
		if current_accumulate_time > 0.1:
			bomb.linear_velocity = Vector2(energy_bar.texture_progress_bar.value * max_throw_power_x * direction.value, max_throw_power_y * energy_bar.texture_progress_bar.value - 150)
		energy_bar.hide()
		current_accumulate_time = 0.0
		energy_bar.texture_progress_bar.value = 0
