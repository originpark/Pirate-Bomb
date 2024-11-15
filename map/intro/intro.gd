class_name Intro
extends Node2D


# 常量
const JUMP_PLATFORM_COLOR: Color = Color(114/255.0, 64/255.0, 128/255.0, 1)

# 互动区域
var interact_body_captain_tip
var interact_body_cucumber_tip
var interact_body_big_guy_tip

# 逻辑工具
var captain_died: bool = false
var cucumber_died: bool = false
var whale_died: bool = false

# 对话控制器
@onready var intro_dialogue_controller: DialogueController = $Storys/IntroDialogueController
@onready var captain_dialogue_controller: DialogueController = $Storys/CaptainDialogueController
@onready var cucumber_dialogue_controller: DialogueController = $Storys/CucumberDialogueController
@onready var bigguy_dialogue_controller: DialogueController = $Storys/BigguyDialogueController

# 角色
@onready var captain: Captain = $Characters/Captain
@onready var cucumber: Cucumber = $Characters/Cucumber
@onready var whale: Whale = $Characters/Whale
@onready var bomb_guy: BombGuy = $Characters/BombGuy

#特殊平台
@onready var platform_single_7: StaticBody2D = $Platforms/PlatformSingle7

# 组件引用
@onready var tile_map_layer: TileMapLayer = $TileMapLayer



func _ready() -> void:
	if not TimeLine.intro_intro:
		intro_dialogue_controller.start()
		TimeLine.intro_intro = true


func _physics_process(delta: float) -> void:
	if interact_body_captain_tip and not TimeLine.intro_captain_tip:
		TimeLine.intro_captain_tip = true
		captain_dialogue_controller.start()
	if interact_body_cucumber_tip and not TimeLine.intro_cucumber_tip:
		TimeLine.intro_cucumber_tip = true
		cucumber_dialogue_controller.start()
	if captain.is_died and not captain_died:
		captain_died = true
		get_tree().create_tween().tween_property(platform_single_7, "modulate", JUMP_PLATFORM_COLOR, 1)
		platform_single_7.constant_linear_velocity.y = -1000
	if (cucumber.is_died and not cucumber_died) and (whale.is_died and not whale_died):
		cucumber_died = true
		whale_died = true
		tile_map_layer.erase_cell(Vector2(15, -7))
	if interact_body_big_guy_tip and not TimeLine.intro_big_tip:
		TimeLine.intro_big_tip = true
		bigguy_dialogue_controller.start()
	if bomb_guy.is_died:
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
