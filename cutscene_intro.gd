extends Control

@export var main_game_scene: PackedScene

@onready var animation_player: AnimationPlayer = $TextureRect/AnimationPlayer


func _ready() -> void:
	if main_game_scene == null:
		push_error("Assign Main Game.tscn in the Inspector.")
		return

	animation_player.play("intro")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(main_game_scene)
