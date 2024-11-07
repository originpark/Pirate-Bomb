class_name Gravity
extends Node
## 重力组件
##
## 使角色体具有重力
## @target关系限制: parent
## #target类型类型: CharacterBody2D
## @应用条件: target需要每帧调用move_and_slide()方法


## 是否开启自定义重力
@export var use_costom_gravity: bool = false

## 自定义重力大小
@export_range(0, 65535) var custom_gravity: float

## 是否由脚本代理开启owner的move_and_slide()方法, 如果关闭, 请手动在owner脚本中调用
@export var move_and_slide_proxy: bool = false 

## 默认重力大小, 如果用户没有自定义重力, 则使用默认重力
var _default_gravity: float = ProjectSettings.get("physics/2d/default_gravity")

## 实际应用的重力大小
var _gravity: float

var _parent: Node2D


func _ready() -> void:
	if get_parent() is not CharacterBody2D:
		set_physics_process(false)
		return
	_parent = get_parent()
	_gravity = custom_gravity if use_costom_gravity else _default_gravity


func _physics_process(delta: float) -> void:
	(_parent as CharacterBody2D).velocity.y += _gravity * delta
	if move_and_slide_proxy:
		(_parent as CharacterBody2D).move_and_slide()
