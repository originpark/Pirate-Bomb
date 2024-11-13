class_name StateMachine
extends Node
## 状态机组件
##

## 初始状态
@export var initial_state: StateBase

##状态字典
var _states: Dictionary = {}

## 当前状态
var current_state: StateBase = null

## 当前状态运行时间
var current_state_run_time: float = 0.0

## 下一状态, 仅在exit方法中有效
var next_state: String = ""

## 历史状态
var _history_states: Array[String] = []

## 消息
var message: Dictionary

var disable: bool = false


func _ready() -> void:
	_before_load()
	for state: StateBase in get_children():
		state.state_machine = self
		state.target = owner
		_states[state.name] = state
	
	await owner.ready
	_before_start()
	if initial_state:
		_add_history_state(initial_state.name)
		initial_state.enter()
		current_state = initial_state
	

func _physics_process(delta: float) -> void:
	if current_state:
		current_state_run_time += delta
		current_state.physics_update(delta)
		

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		

func change_state(from: StateBase, to: String) -> void:
	#print(from.name, " -> ", to)
	var cs: StateBase = current_state
	current_state = null
	
	#if cs != from:
		#print("warning: current_state与from不一致, from: ", from, " current_state: ", cs)
		#return
	
	var new_state: StateBase = _states.get(to)
	if !new_state:
		print("error: 不存在状态: ", to)
		return
	next_state = new_state.name
	if cs:
		cs.exit()
	next_state = ""
	_add_history_state(new_state.name)
	new_state.enter()
	current_state_run_time = 0.0
	current_state = new_state


func _add_history_state(state_name: String) -> void:
	_history_states.append(state_name)
	if _history_states.size() > 20:
		_history_states.remove_at(0)
	

## 获取历史状态, 参数为回退的步数, 例如history_state(1)表示上一个状态
func history_state(back: int) -> String:
	var pos := _history_states.size() - 1 - back
	if pos < 0:
		#print("message: 获取回退", back, "步的历史状态名失败, pos: ", pos)
		return ""
	else:
		return _history_states[pos]


func _before_load() -> void:
	pass


func _before_start() -> void:
	pass


func set_message(key: String, value) -> void:
	message[key] = value
	

func get_message(key: String) -> Object:
	if message.has(key):
		if not is_instance_valid(message[key]):
			message.erase(key)
			return null
		return message[key]
	else:
		return null
