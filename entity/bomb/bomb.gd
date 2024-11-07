class_name Bomb
extends RigidBody2D


@onready var animation_player: AnimationPlayer = $Graphics/AnimationPlayer

var dust_count: int = 0


func _ready() -> void:
	animation_player.play("on")
	contact_monitor = true
	max_contacts_reported = 10
	get_tree().create_timer(3).timeout.connect(_on_bomb_timer_time_out)


func _physics_process(delta: float) -> void:
	if get_contact_count() != 0 and (abs(linear_velocity.y) as int) > 30:
		var dust: Dust = DustCreator.generate(DustCreator.FALL_DUST, get_tree().current_scene, global_position)
		dust.free_deferred()
	modulate.r += 0.005


func _on_bomb_timer_time_out() -> void:
	modulate.r = 1
	animation_player.play("explotion")
	await animation_player.animation_finished
	queue_free()


func is_on_floor() -> bool:
	return (abs(linear_velocity.y) as int) == 0
