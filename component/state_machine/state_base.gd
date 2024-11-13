class_name StateBase
extends Node
## 状态类父节点

## 所属状态机
var state_machine: StateMachine

## 所属对象
var target


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	pass


func transition_to(to: String) -> void:
	state_machine.change_state(self, to)
