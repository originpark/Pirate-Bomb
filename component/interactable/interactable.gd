class_name Interactable
extends Area2D
## 使owner拥有可检测其他区域或碰撞体的区域
##
## @target关系限制: parent / owner
## @target类型限制: Node2D
## 应用条件: 如果希望检测到其他body/area的进入, 需要target中存在interact_body_class_name/interact_area_class_name属性
## 进入的body/area会被自动存入该属性
## 如果希望保存一个body/area的列表, 则属性需要是名称为interact_body_list_class_name的数组


enum Target {OWNER, PARENT}

## 是否检测其他body的进入
@export var connect_body_entered: bool = false:
	set(v):
		connect_body_entered = v
		_update_connect(connect_body_entered, body_entered, _on_interactable_body_entered)

## 是否检测其他body的离开
@export var connect_body_exited: bool = false:
	set(v):
		connect_body_exited = v
		_update_connect(connect_body_exited, body_exited, _on_interactable_body_exited)

## 是否检测其他area的进入
@export var connect_area_entered: bool = false:
	set(v):
		connect_area_entered = v
		_update_connect(connect_area_entered, area_entered, _on_interactable_area_entered)

## 是否检测其他area的离开
@export var connect_area_exited: bool = false:
	set(v):
		connect_area_exited = v
		_update_connect(connect_area_exited, area_exited, _on_interactable_area_exited)


## 挂载目标
@export var target: Target

var _target: Node2D

var _name_format: String

var _check_body_entered: bool = false
var _check_body_list_entered: bool = false

var _check_body_exited: bool = false
var _check_body_list_exited: bool = false

var _check_area_entered: bool = false
var _check_area_list_entered: bool = false

var _check_area_exited: bool = false
var _check_area_list_exited: bool = false


func _ready() -> void:
	if target == Target.OWNER:
		_target = owner
	elif target == Target.PARENT:
		_target = get_parent()
	_name_format = name.capitalize().replace(" ", "_").to_lower()
	_check_body_entered = true if ("interact_body_" + _name_format) in _target else false
	_check_body_list_entered = true if ("interact_body_list_" + _name_format) in _target else false
	_check_body_exited = _check_body_entered
	_check_body_list_exited = _check_body_list_entered
	_check_area_entered = true if ("interact_area_" + _name_format) in _target else false
	_check_area_list_entered = true if ("interact_body_list_" + _name_format) in _target else false
	_check_area_list_entered = _check_area_entered
	_check_area_list_exited = _check_area_exited


func _on_interactable_body_entered(body: Node2D) -> void:
	if body != _target:
		if _check_body_entered:
			_target.set("interact_body_" + _name_format, body)
		if _check_body_list_entered:
			(_target.get("interact_body_list_" + _name_format) as Array).append(body)


func _on_interactable_body_exited(body: Node2D) -> void:
	if _check_body_exited:
		_target.set("interact_body_" + _name_format, null)
	if _check_body_list_exited:
		(_target.get("interact_body_list_" + _name_format) as Array).erase(body)


func _on_interactable_area_entered(area: Area2D) -> void:
	if area != _target:
		if _check_area_entered:
			_target.set("interact_area_" + _name_format, area)
		if _check_area_list_entered:
			(_target.get("interact_area_list_" + _name_format) as Array).append(area)
	

func _on_interactable_area_exited(area: Area2D) -> void:
	if _check_area_exited:
		_target.set("interact_area_" + _name_format, null)
	if _check_area_list_exited:
		(_target.get("interact_area_list_" + _name_format) as Array).erase(area)


func _update_connect(is_connect: bool, s: Signal, callback: Callable) -> void:
	if is_connect:
		if not s.is_connected(callback):
			s.connect(callback)
	else:
		if s.is_connected(callback):
			s.disconnect(callback)
