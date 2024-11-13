class_name BombExplotion
extends StateBase


func enter() -> void:
	target.modulate.r = 1
	target.animation_player.play("explotion")
	var list: Array = (target as Bomb).interact_body_list_explotion_area
	for obj in list:
		if (obj as Node2D).stats:
			Effect.physics_attack(target.stats, obj.stats)
	await target.animation_player.animation_finished
	target.queue_free()
