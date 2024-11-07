@tool
class_name Camera
extends Camera2D


func _ready() -> void:
	limit_smoothed = true
	position_smoothing_enabled = true
	drag_horizontal_enabled = true
	drag_vertical_enabled = true
	var tilemap_layer:TileMapLayer  = owner.find_child("TileMapLayer")
	if not tilemap_layer:
		return
	var used_rect := tilemap_layer.get_used_rect()
	var tile_size := tilemap_layer.tile_set.tile_size
	limit_top = used_rect.position.y * tile_size.y
	limit_bottom = used_rect.end.y * tile_size.y
	limit_left = used_rect.position.x * tile_size.x
	limit_right = used_rect.end.x * tile_size.x
	reset_smoothing()


func _get_configuration_warnings() -> PackedStringArray:
	var tile_map_layer := owner.find_child("TileMapLayer")
	if not tile_map_layer:
		return ["在当前场景树中没有找到TileMapLyer节点, camera无法根据地图调整相机视角限制"]
	else:
		return []
