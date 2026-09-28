extends Node

@export var main_menu_scene: PackedScene
@export var ending_duration := 8.0


func _ready() -> void:
	await get_tree().create_timer(ending_duration).timeout

	if main_menu_scene == null:
		push_error("Assign Main Menu Scene in this ending's Inspector.")
		return

	get_tree().change_scene_to_packed(main_menu_scene)
