class_name Dust
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func free_deferred() -> void:
	if animated_sprite_2d.sprite_frames.get_animation_loop("default"):
		await animated_sprite_2d.animation_looped
	else:
		await animated_sprite_2d.animation_finished
	queue_free()
