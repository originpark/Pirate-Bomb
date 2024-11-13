class_name BombOn
extends StateBase




func enter() -> void:
	target.animation_player.play("on")
	target.contact_monitor = true
	target.max_contacts_reported = 10


func physics_update(delta: float) -> void:
	if target.is_off:
		transition_to("BombOff")
		return
	if target.explotion:
		transition_to("BombExplotion")
		return
	if target.is_take:
		transition_to("BombTake")
		return
	if target.get_contact_count() != 0 and (abs(target.linear_velocity.y) as int) > 30:
		var dust: Dust = DustCreator.generate(DustCreator.FALL_DUST, get_tree().current_scene, target.global_position)
		dust.free_deferred()
	target.modulate.r += 0.005
