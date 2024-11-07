class_name DustCreator
extends Node


const FALL_DUST = preload("res://entity/dust/fall_dust.tscn")
const JUMP_DUST = preload("res://entity/dust/jump_dust.tscn")
const RUN_DUST = preload("res://entity/dust/run_dust.tscn")


static func generate(dust_scene: PackedScene, _parent: Node2D, pos: Vector2) -> Dust:
	var dust_obj := dust_scene.instantiate()
	_parent.add_child(dust_obj)
	dust_obj.position = pos
	return dust_obj
	
