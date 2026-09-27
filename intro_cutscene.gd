extends Node2D

@export var main_game_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if main_game_scene == null:
		push_error("Assign Main Game.tscn to Main Game Scene in the Inspector.")
		return

	var animation_name := animation_player.autoplay
	if animation_name.is_empty():
		push_error("Set an Autoplay animation on AnimationPlayer.")
		return

	var duration := animation_player.get_animation(animation_name).length
	animation_player.play(animation_name)

	await get_tree().create_timer(duration).timeout

	var result := get_tree().change_scene_to_packed(main_game_scene)
	if result != OK:
		push_error("Could not open Main Game scene: " + error_string(result))
