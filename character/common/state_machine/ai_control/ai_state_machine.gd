class_name AIStateMachine
extends StateMachine

enum TrackMode {
	## 只追踪在同一水平面的目标
	GROUND_ONLY,
	## 可以跳跃或降落来追踪不同高度的目标
	JUMP_ENABLE
}



@export_category("AiIdle")
## 闲逛时转身概率
@export_range(0, 1) var turn_around_percentage: float
@export_group("Stand Time", "stand_time")
## 站立时间最大值
@export_range(0, 10) var stand_time_max: float
## 站立时间最小值
@export_range(0, 10) var stand_time_min: float
@export_group("Move Time", "move_time")
## 移动时间最大值
@export_range(0, 10) var move_time_max: float
## 移动时间最小值
@export_range(0, 10) var move_time_min: float
## 检测墙壁的射线的长度
@export_range(0, 100) var wall_ray_cast_length: float

@export_category("AiTrack")
## 对目标的追踪模式
@export var track_mode: TrackMode
## 判定与炸弹接触的坐标相对于目标坐标的位置偏移 
@export_range(0, 500) var bomb_track_offset: float
## 判定与人物接触的坐标相对于目标坐标的位置偏移 
@export_range(0, 500) var character_track_offset: float
## 判定掉落的坐标相对于目标坐标的位置偏移
@export_range(-100, 100) var fall_offset: float
## 失去目标后的冷静时间
@export_range(0, 10) var cool_time: float

var floor_ray_cast: RayCast2D
var wall_ray_cast: RayCast2D
var jump_height: float


var ai_state: Dictionary = {
	AiIdle = preload("res://character/common/state_machine/ai_control/state/ai_idle.gd"),
	AiTrack = preload("res://character/common/state_machine/ai_control/state/ai_track.gd"),
}


func _before_load() -> void:
	for state in ai_state:
		var state_instancs = ai_state[state].new()
		state_instancs.name = state
		add_child(state_instancs)


func _before_start() -> void:
	initial_state = _states["AiIdle"]
	floor_ray_cast = RayCast2D.new()
	owner.graphics.add_child(floor_ray_cast)
	floor_ray_cast.position = Vector2(fall_offset, -1)
	floor_ray_cast.target_position = Vector2(0, 5)
	floor_ray_cast.set_collision_mask_value(1, false)
	floor_ray_cast.set_collision_mask_value(2, true)
	wall_ray_cast = RayCast2D.new()
	owner.graphics.add_child(wall_ray_cast)
	wall_ray_cast.position = Vector2(0, -1)
	wall_ray_cast.target_position = Vector2(wall_ray_cast_length, 0)
	wall_ray_cast.set_collision_mask_value(1, false)
	wall_ray_cast.set_collision_mask_value(2, true)
	
	var g = owner.gravity._gravity
	var t = abs(owner.jump_power / g)
	jump_height = (-owner.jump_power) * t - 0.5 * g * t * t
