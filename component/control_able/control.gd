class_name ControlAble
extends Node
## 使对象命名以action_开头的属性与InputMap绑定
##
## @target关系限制: parent
## @target限制: Node
## @应用条件: 如果希望监测action_xxx的just_pressed事件是否发生, 只需在owner中存在变量action_just_pressed_xxx, 该变量
## 的值将自动与该事件绑定
## 如果希望禁用输入控制, 请为owner添加action_lock变量, 并设置为false


## 获取axis时的负方向
@export var axis_negative_action: String = "action_left"

## 获取axis时的正方向
@export var axis_position_action: String = "action_right"

var action_list: Array[Action]

var _parent: Node


func _ready() -> void:
	if get_parent() is not Node:
		set_physics_process(false)
		return
	_parent = get_parent()
	var action_bind_var_list: Array[String]
	var property_list: Array[Dictionary] = _parent.get_property_list()
	for property in property_list:
		if (property.name as String).begins_with("action_"):
			action_bind_var_list.append(property.name)
	for action_str in action_bind_var_list:
		var action: Action
		var slices := action_str.split("_")
		if not slices or slices.size() < 3:
			continue
		var action_emit_mode: String
		var action_name: String
		if slices[1] == "get":
			action_emit_mode = action_str.substr(7)
			action_name = ""
			action = Action.new(action_str, action_name, action_emit_mode)
		else:
			for i in range(1, slices.size() - 1):
				action_emit_mode += slices[i] + "_"
			action_emit_mode = action_emit_mode.trim_suffix("_")
			action_name = slices[0] + "_" + slices[slices.size() - 1]
			action = Action.new(action_str, action_name, action_emit_mode)
		if action:
			action_list.append(action)


func _physics_process(_delta: float) -> void:
	if _parent.get("action_lock"):
		return
	for action in action_list:
		match action.action_emit_mode:
			"just_pressed":
				_parent.set(action.bind_name, true if Input.is_action_just_pressed(action.action_name) else false)
			"pressed":
				_parent.set(action.bind_name, true if Input.is_action_pressed(action.action_name) else false)
			"get_axis":
				_parent.set(action.bind_name, Input.get_axis(axis_negative_action, axis_position_action))
			"just_released":
				_parent.set(action.bind_name, true if Input.is_action_just_released(action.action_name) else false)



class Action:
	var bind_name: String
	var action_name: String
	var action_emit_mode: String
	
	func _init(_bind_name: String, _action_name: String, _action_emit_mode: String) -> void:
		self.bind_name = _bind_name
		self.action_name = _action_name
		self.action_emit_mode = _action_emit_mode
		
