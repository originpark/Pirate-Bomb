class_name Decelerate
extends Node


@export_range(0, 100) var acceleration: int

var start: bool = false
var action_lock: bool


func _ready() -> void:
	await owner.ready
	action_lock = owner.action_lock


func _physics_process(delta: float) -> void:
	if start:
		owner.v_lock = true
		owner.velocity.x = move_toward(owner.velocity.x, 0, acceleration)
		if abs(owner.velocity.x) == 0:
			start = false
			owner.v_lock = false
