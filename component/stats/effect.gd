class_name Effect
extends Node


static func physics_attack(origin: Stats, target: Stats) -> void:
	target.owner.v_lock = true
	target.owner.is_hurt = true
	target.heart -= origin.physics_attack
	if target.back_off_enable:
		if target.owner is CharacterBody2D:
			var back_dir = -1 if (target.owner.global_position.x - origin.owner.global_position.x) < 0 else 1 
			target.owner.decelerate.start = true
			(target.owner as CharacterBody2D).velocity = Vector2(back_dir * (origin.back_off_power.x - target.back_off_defence), origin.back_off_power.y)
