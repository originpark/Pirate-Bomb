class_name Stats
extends Node


@export var back_off_enable: bool

@export_range(0, 100) var max_heart: int
var heart: int

@export_range(0, 100) var physics_attack: int

@export var back_off_power: Vector2

@export_range(0, 300) var back_off_defence: int


func _ready() -> void:
	heart = max_heart
