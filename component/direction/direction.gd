@tool
class_name Direction
extends Node
## 方向组件
##
## 使对象拥有方向属性
## @target关系限制: parent
## @target类型限制: Node2D
## @应用条件: 如果希望方向变化时自动更新图形翻转, 请确保将图形资源节点放在名为Graphics(Node2D)的节点下

## 方向枚举
enum DirValue{POSITIVE = 1, NEGATIVE = -1}

## 方向变化时,是否自动更新图形节点的翻转
## 如果为true, 我们会自动寻找owner下的名为Graphics的节点, 当value变化时, 会同步修改Graphics的scale属性
## 这可以用于根据方向自动更新图形资源的翻转
@export var bind_graphics_scale: bool = false:
	set(v):
		bind_graphics_scale = v
		update_configuration_warnings()


var value: int = DirValue.POSITIVE:
	set(v):
		if not (v == DirValue.POSITIVE or v == DirValue.NEGATIVE):
			return
		value = v
		if _graphics:
			_graphics.scale.x = value

var _graphics: Node2D:
	set(v):
		_graphics = v
		update_configuration_warnings()


func _ready() -> void:
	if get_parent() is not Node2D:
		return
	if bind_graphics_scale:
		_graphics = get_parent().find_child("Graphics")


func _get_configuration_warnings() -> PackedStringArray:
	if bind_graphics_scale:
		_graphics = get_parent().find_child("Graphics")
	if bind_graphics_scale and not _graphics:
		return ["在根节点中没有找到为名Graphics(Node2D)的直接子节点, 如果不想绑定缩放, 请关闭bind_graphics_scale"]
	else:
		return []
