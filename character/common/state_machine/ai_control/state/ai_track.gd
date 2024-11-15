class_name AiTrack
extends StateBase


var track_obj: Node2D
var target_detected: bool = false
var lose_target_timer: Timer
var jump_reset_timer: Timer
var target_jump: bool = false
var cache_platform: StaticBody2D
var try_to_fall: bool = false
var flag: bool = false
var floor_turn_around: bool = false
var left_disable: bool = false
var right_disable: bool = false
var jump: bool = false


func _ready() -> void:
	#Engine.time_scale = 0.5
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
		#print(get_tree().get_frame(), " ai状态机已被禁用")
		track_obj = null
		return
	#print(get_tree().get_frame(), " 准备寻找目标")
	var find = find_target()
	#print(get_tree().get_frame(), " 寻找到的目标是: ", find)
	if find:
		#print(get_tree().get_frame(), " find存在, 将其赋值给target_obj")
		track_obj = find
		target_detected = true
		if not lose_target_timer.is_stopped():
			#print(get_tree().get_frame(), " 停止lose_target_timer的计时")
			lose_target_timer.stop()
	elif not is_instance_valid(track_obj) or (not find and track_obj and track_obj is Bomb) or (track_obj is CharacterBody2D and track_obj.is_died):
		#print(get_tree().get_frame(), " find不存在, 并且target_obj已经被释放, 或者target_obj是炸弹 或 已经死亡的角色, 经target_obj置空")
		track_obj = null
	elif track_obj and target_detected:
		#print(get_tree().get_frame(), " find不存在, 开启lose_target_timer计时器")
		if not is_instance_valid(track_obj):
			track_obj = null
		else:
			target_detected = false  
			lose_target_timer.start(3)
	if track_obj:
		#print(get_tree().get_frame(), " target_obj存在, 开始寻路: ", track_obj)
		track(track_obj)
	else:
		#print(get_tree().get_frame(), " target_obj不存在, 切换为AiIdle状态")
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
			if bomb.is_off and (target is not BigGuy and target is not Whale):
				continue
			var distance := (bomb as Bomb).global_position.distance_to(target.global_position)
			if distance < min_distance:
				min_distance = distance
				ret = bomb
	if not ret and character and not character.is_died:
		ret = character
	if not ret:
		ret = null
	return ret


## 追踪track_obj目标
func track(obj: Node2D) -> void:
	#print(get_tree().get_frame(), " **********新的track****************")
	if target is Captain and obj is Bomb:
		#print(get_tree().get_frame(), " 目标是炸弹, 且我是Captain, 直接进入Captain的躲避炸弹模式, track结束")
		(target.basic_state_machine as StateMachine).set_message("target_bomb", track_obj) 
		target.action_just_pressed_secondary = true
		return
	if not target.is_on_floor():
		#print(get_tree().get_frame(), " 我在空中, 保持原样 track结束")
		return 
	var pos := obj.global_position as Vector2i
	var my_pos := (target as Node2D).global_position as Vector2i
	var distance := (pos - my_pos).abs()
	var dir := pos - my_pos
	#print(get_tree().get_frame(), " 目标的坐标: ", pos, ", 我的坐标: ", my_pos, ", 距离: ", distance, ", 方向向量: ", dir)
	if (state_machine as AIStateMachine).wall_ray_cast.is_colliding():
		#print(get_tree().get_frame(), " 撞墙了, 转向")
		target.action_get_axis = target.direction.value * -1
	if dir.y == 0 or dir.y == 1 or dir.y == -1:
		#print(get_tree().get_frame(), " 目标和我在同一高度")
		if obj is Bomb and distance.x <= (state_machine as AIStateMachine).bomb_track_offset or obj is CharacterBody2D and distance.x <= (state_machine as AIStateMachine).character_track_offset:
			#print(get_tree().get_frame(), " 和目标之间距离小于指定长度, 成功追踪到目标, 停止移动")
			target.action_get_axis = 0
			if track_obj is Bomb:
				#print(get_tree().get_frame(), " 对象是炸弹")
				(target.basic_state_machine as StateMachine).set_message("target_bomb", track_obj) 
				target.action_just_pressed_secondary = true
			elif track_obj is CharacterBody2D:
				#print(get_tree().get_frame(), " 对象是player")
				(target.basic_state_machine as StateMachine).set_message("target_character", track_obj)
				target.action_just_pressed_primary = true
			#print(get_tree().get_frame(), " track结束")
			return
		else:
			#print(get_tree().get_frame(), " 向目标移动, track结束")
			target.action_get_axis = 1 if dir.x > 0 else -1
	elif dir.y > 0:
		#print(get_tree().get_frame(), " 目标在我下方")
		if try_to_fall and not target.is_on_floor():
			#print(get_tree().get_frame(), " 成功坠落")
			try_to_fall = false
		if not try_to_fall:
			#print(get_tree().get_frame(), " 向目标方向移动, 尝试坠落")
			target.action_get_axis = 1 if dir.x > 0 else -1
			try_to_fall = true
	elif track_obj.is_on_floor():
		#print(get_tree().get_frame(), " 目标在我上方, 并且在地板上")
		var platform: StaticBody2D
		if target.is_on_floor() and not target.action_just_pressed_jump:
			#print(get_tree().get_frame(), " 我在地板上, 开始获取目标平台")
			platform = get_target_platform(my_pos, true)
			cache_platform = platform
		else:
			#print(get_tree().get_frame(), " 我处于跳跃或降落状态, 不获取平台, 平台为缓存值: ", cache_platform)
			platform = cache_platform
		if platform:
			#print(get_tree().get_frame(), " 平台存在: ", platform.name)
			#print("平台存在, ", platform.name)
			var p := platform.global_position as Vector2i
			if can_jump(my_pos, p):
				if target.is_on_floor():
					#print(get_tree().get_frame(), " 可以跳跃且我在地板上, 重置left, right平台禁用")
					left_disable = false
					right_disable = false
					if abs(my_pos.x - p.x) <= 30:
						#print(get_tree().get_frame(), " 水平距离小于30, 直接垂直起跳, track结束")
						target.action_get_axis = 0
					else:
						target.action_get_axis = 1 if p.x > my_pos.x else -1
						#print(get_tree().get_frame(), " 跳跃时朝着目标平台的方向水平移动: ", target.action_get_axis)
					#print(get_tree().get_frame(), " 开始跳跃, 计时器开始计时, track结束")
					target.action_just_pressed_jump = true
					jump_reset_timer.start(0.1)
				else:
					#print(get_tree().get_frame(), " 可以跳跃但是我不在地板上, 不起跳, track结束")
					pass
			else:
				if not (state_machine as AIStateMachine).floor_ray_cast.is_colliding() and not flag:
					target.action_get_axis = target.direction.value * -1
					#print(get_tree().get_frame(), " 朝着目标平台的方向移动的过程中碰到了悬崖, 该平台不可直接到达, 反向: ", target.action_get_axis, " track结束")
					flag = true
					if pos.x > my_pos.x:
						right_disable = true
						#print(get_tree().get_frame(), " 目标在我右边, 暂时禁用右边的平台")
					else:
						left_disable = true
						#print(get_tree().get_frame(), " 目标在我右边, 暂时禁用左边的平台")
				if not flag:
					target.action_get_axis = 1 if p.x > my_pos.x else -1
					#print(get_tree().get_frame(), " 水平方向不够, 不能跳, 并且暂时没有碰到悬崖, 先朝着目标平台的方向移动: ", target.action_get_axis, " track结束")
				else:
					#print(get_tree().get_frame(), " 刚刚碰到了悬崖, 正在反向移动中: ", target.action_get_axis)				
					pass
	else:
		#print(get_tree().get_frame(), " 目标在我上方, 但是在空中, track结束")
		pass


## 根据目标方向获取最近的可跳跃平台
func get_target_platform(my_pos: Vector2i, on_top: bool) -> StaticBody2D:
	var platforms := get_tree().get_nodes_in_group("platform")
	platforms = platforms.filter(func (platform): return (platform.global_position as Vector2).distance_to(my_pos) <= 250)
	var left := platforms.filter(func (platform): return (platform.global_position as Vector2i).x <= my_pos.x)
	var right := platforms.filter(func (platform): return (platform.global_position as Vector2i).x > my_pos.x)
	var nearest_left := get_nearest_platform(left, my_pos, on_top)
	var nearest_right := get_nearest_platform(right, my_pos, on_top)
	if left_disable:
		#print(get_tree().get_frame(), " 由于左侧平台被禁用, nearest_left = null")
		nearest_left = null
	if right_disable:
		#print(get_tree().get_frame(), " 由于右侧平台被禁用, nearest_right = null")
		nearest_right = null
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
		if on_top and (abs(pos.y - my_pos.y) <= 1 or pos.y > my_pos.y):
			continue
		if (state_machine as AIStateMachine).jump_height < abs(pos.y - my_pos.y):
			continue
		var distance = platform.global_position.distance_to(my_pos)
		if distance < min_distance:
			min_distance = distance
			ret = platform
	return ret


func can_jump(my_pos: Vector2i, pos: Vector2i) -> bool:
	#print(get_tree().get_frame(), " 开始判断是否能跳到目标平台")
	var distance_x = abs(my_pos.x - pos.x)
	var distance_y = abs(my_pos.y - pos.y)
	distance_x = distance_x if distance_x <= 32 else distance_x - 30
	if distance_y > (state_machine as AIStateMachine).jump_height:
		#print(get_tree().get_frame(), " 目标平台高度大于我能跳到的最大高度, false")
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
			#print(get_tree().get_frame(), " 可以跳到, true")
			return true
	elif discriminant == 0:
		var t = -b / (2.0 * a)
		var x = target.run_speed * t
		if x >= distance_x:
			#print(get_tree().get_frame(), " 可以跳到, true")
			return true
	#print(get_tree().get_frame(), " 水平距离过远, false")
	return false
