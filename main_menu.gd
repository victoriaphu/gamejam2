extends Node2D

var button_type = null


func _on_start_game_pressed() -> void:
	button_type = "Start Game"
	$"fade transition".show()
	$"fade transition/fade timer".start()
	$"fade transition/ColorRect/AnimationPlayer".play("fade in")


func _on_options_pressed() -> void:
	button_type = "Options"
	$"fade transition".show()
	$"fade transition/fade timer".start()
	$"fade transition/ColorRect/AnimationPlayer".play("fade in")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fade_timer_timeout() -> void:
	if button_type == "Start Game":
		get_tree().change_scene_to_file("res://cutscene_intro.tscn")
	elif button_type == "Options":
		pass
