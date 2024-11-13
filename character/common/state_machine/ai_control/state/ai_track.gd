class_name AiTrack
extends StateBase


var track_obj: Node2D
var target_detected: bool = false
var lose_target_timer: Timer
var jump_reset_timer: Timer
var target_jump: bool = false
var chache_platform: StaticBody2D
var try_to_fall: bool = false


func _ready() -> void:
	lose_target_timer = Timer.new()
	lose_target_timer.one_shot = true
	lose_target_timer.timeout.connect(func (): track_obj = null)
	add_child(lose_target_timer)
	
	jump_reset_timer = Timer.new()
	jump_reset_timer.one_shot = true
	jump_reset_timer.timeout.connect(func(): target.action_just_pressed_jump = false)
	add_child(jump_reset_timer)


func physics_update(delta: float) -> void:
	if state_machine.disable:
		track_obj = null
		return
	var find = find_target()
	if find:
		track_obj = find
		target_detected = true
		if not lose_target_timer.is_stopped():
			lose_target_timer.stop()
	elif not is_instance_valid(track_obj) or (not find and track_obj and track_obj is Bomb) or (track_obj is CharacterBody2D and track_obj.is_died):
		track_obj = null
	elif track_obj and target_detected:
		if not is_instance_valid(track_obj):
			track_obj = null
		else:
			target_detected = false  
			lose_target_timer.start(3)
		
		
	if track_obj:
		track(track_obj)
	else:
		transition_to("AiIdle")


## 寻找视野范围内的目标并返回
func find_target() -> Node2D:
	target.update_interact_bomb_list()
	var bomb_list: Array[Bomb] = target.interact_body_list_bomb_sight
	var character: CharacterBody2D = target.interact_body_character_sight
	var ret
	if bomb_list.size() > 0:
		var min_distance := 65535.0
		for bomb in bomb_list:
			if bomb.is_off and target is not BigGuy:
				continue
			var distance := (bomb as Bomb).global_position.distance_to(target.global_position)
			if distance < min_distance:
				min_distance = distance
				ret = bomb
	elif character and not character.is_died:
		ret = character
	else:
		ret = null
	return ret


## 追踪track_obj目标
func track(obj: Node2D) -> void:
	if target is Captain and obj is Bomb:
		(target.basic_state_machine as StateMachine).set_message("target_bomb", track_obj) 
		target.action_just_pressed_secondary = true
		return
	var pos := obj.global_position as Vector2i
	var my_pos := (target as Node2D).global_position as Vector2i
	var distance := (pos - my_pos).abs()
	var dir := pos - my_pos
	if (state_machine as AIStateMachine).wall_ray_cast.is_colliding():
		target.action_get_axis = target.direction.value * -1
	if dir.y == 0 or dir.y == 1 or dir.y == -1:
		if obj is Bomb and distance.x <= (state_machine as AIStateMachine).bomb_track_offset or obj is CharacterBody2D and distance.x <= (state_machine as AIStateMachine).character_track_offset:
			target.action_get_axis = 0
			if track_obj is Bomb:
				(target.basic_state_machine as StateMachine).set_message("target_bomb", track_obj) 
				target.action_just_pressed_secondary = true
			elif track_obj is CharacterBody2D:
				(target.basic_state_machine as StateMachine).set_message("target_character", track_obj)
				target.action_just_pressed_primary = true 
			return			
		else:
			target.action_get_axis = 1 if dir.x > 0 else -1
	elif dir.y > 0:
		if not try_to_fall:
			target.action_get_axis = 1 if dir.x > 0 else -1
			try_to_fall = true
	elif track_obj.is_on_floor():
		var platform: StaticBody2D
		if target.is_on_floor():
			platform = get_target_platform(my_pos, true)
			chache_platform = platform
		else: 
			platform = chache_platform
		if platform:
			var p := platform.global_position as Vector2i
			if can_jump(my_pos, platform.global_position) and target.is_on_floor():
				if my_pos.x == pos.x:
					target.action_get_axis = 0
				else:
					if abs(my_pos.x - p.x) <= 30:
						target.action_get_axis = 0
					else:
						target.action_get_axis = 1 if p.x > my_pos.x else -1
				target.action_just_pressed_jump = true
				jump_reset_timer.start(0.1)
			else:
				if abs(my_pos.x - p.x) <= 30:
					target.action_get_axis = 0
				else:
					target.action_get_axis = 1 if p.x > my_pos.x else -1
				if not (state_machine as AIStateMachine).floor_ray_cast.is_colliding() and target.is_on_floor():
					if target.direction.value == 1 and my_pos.x > p.x or target.direction.value == -1 and my_pos.x < p.x:
						target.action_just_pressed_jump = true
						jump_reset_timer.start(0.1)


## 根据目标方向获取最近的可跳跃平台
func get_target_platform(my_pos: Vector2i, on_top: bool) -> StaticBody2D:
	var platforms := get_tree().get_nodes_in_group("platform")
	var left := platforms.filter(func (platform): return (platform.global_position as Vector2i).x <= my_pos.x)
	var right := platforms.filter(func (platform): return (platform.global_position as Vector2i).x > my_pos.x)
	var nearest_left := get_nearest_platform(left, my_pos, on_top)
	var nearest_right := get_nearest_platform(right, my_pos, on_top)
	var obj_on_left = true if (track_obj.global_position as Vector2i).x < my_pos.x else false
	if obj_on_left and nearest_left:
		return nearest_left
	elif not obj_on_left and nearest_right:
		return nearest_right
	else:
		return nearest_left if nearest_left else nearest_right


## 获取最近的可跳跃平台
func get_nearest_platform(list: Array, my_pos: Vector2i, on_top: bool) -> StaticBody2D:
	if list.size() == 0:
		return null
	var ret: StaticBody2D
	var min_distance := 65535.0
	for platform in list:
		var pos := platform.global_position as Vector2i
		if on_top and pos.y >= my_pos.y:
			continue
		if (state_machine as AIStateMachine).jump_height < abs(pos.y - my_pos.y):
			continue
		var distance = platform.global_position.distance_to(my_pos)
		if distance < min_distance:
			min_distance = distance
			ret = platform
	return ret


func can_jump(my_pos: Vector2i, pos: Vector2i) -> bool:
	var distance_x = abs(my_pos.x - pos.x)
	var distance_y = abs(my_pos.y - pos.y)
	distance_x = distance_x if distance_x <= 32 else distance_x - 30
	if distance_y > (state_machine as AIStateMachine).jump_height:
		return false
	var a = - (1/2.0 * 1500)
	var b = -target.jump_power
	var c = - distance_y
	var discriminant = b * b - 4 * a * c
	if discriminant > 0:
		var t1 = (-b + sqrt(discriminant)) / (2.0 * a)
		var t2 = (-b - sqrt(discriminant)) / (2.0 * a)
		var x1 = (target.run_speed * t1) as int
		var x2 = (target.run_speed * t2) as int
		if x1 >= distance_x or x2 >= distance_x:
			return true
	elif discriminant == 0:
		var t = -b / (2.0 * a)
		var x = target.run_speed * t
		if x >= distance_x:
			return true
	return false
