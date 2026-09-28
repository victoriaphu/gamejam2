extends Node

# Add each section's lights in the order they should turn on.
@export var guide_lights: Array[PointLight2D] = [] # Section 1
@export var section_2_lights: Array[PointLight2D] = []
@export var section_3_lights: Array[PointLight2D] = []

# Ending scenes and lantern count thresholds.
@export var cutscene_scene: PackedScene # Fallback if endings are not assigned yet
@export var low_ending_scene: PackedScene
@export var middle_ending_scene: PackedScene
@export var high_ending_scene: PackedScene
@export var middle_ending_min := 3
@export var high_ending_min := 6

# Optional HUD label.
@export var lantern_counter_label: Label

@onready var fade_player: AnimationPlayer = $"fade transition/ColorRect/AnimationPlayer"
@onready var canvas: CanvasModulate = $CanvasModulate
@onready var dim_color: Color = canvas.color

var lanterns_collected := 0
var current_section := 1
var section_started := [false, false, false]
var cutscene_started := false
var canvas_tween: Tween


func _ready() -> void:
	_turn_off_lights(guide_lights)
	_turn_off_lights(section_2_lights)
	_turn_off_lights(section_3_lights)
	_update_counter()
	fade_player.play("fade out")


# FIRST lantern in section 1.
func _on_lantern_picked_up() -> void:
	_collect_lantern()
	_start_section_lights(1)


# FIRST lantern in section 2.
func _on_section_2_first_lantern_picked_up() -> void:
	_collect_lantern()
	_start_section_lights(2)


# FIRST lantern in section 3.
func _on_section_3_first_lantern_picked_up() -> void:
	_collect_lantern()
	_start_section_lights(3)


# Every other collectible lantern.
func _on_other_lantern_picked_up() -> void:
	_collect_lantern()


func _collect_lantern() -> void:
	lanterns_collected += 1
	_update_counter()


func _start_section_lights(section: int) -> void:
	if current_section != section:
		return

	if section_started[section - 1]:
		return

	section_started[section - 1] = true
	_light_section(section)


func _light_section(section: int) -> void:
	var lights := _get_section_lights(section)
	if lights.is_empty():
		return

	var starting_color := canvas.color

	for i in range(lights.size()):
		await get_tree().create_timer(0.6).timeout

		# Stop if Jingyue has already entered another section.
		if current_section != section:
			return

		var light := lights[i]
		if is_instance_valid(light):
			light.enabled = true

		var progress := float(i + 1) / float(lights.size())
		var next_color := starting_color.lerp(Color.WHITE, progress)
		_tween_canvas(next_color)


func _get_section_lights(section: int) -> Array[PointLight2D]:
	match section:
		1:
			return guide_lights
		2:
			return section_2_lights
		3:
			return section_3_lights
		_:
			return []


func _turn_off_lights(lights: Array[PointLight2D]) -> void:
	for light in lights:
		if is_instance_valid(light):
			light.enabled = false


func _enter_section(section: int, body: Node2D) -> void:
	if body != $Jingyue or section <= current_section:
		return

	current_section = section
	_tween_canvas(dim_color)


# Connect Section2Trigger's body_entered signal to this.
func _on_section_2_trigger_body_entered(body: Node2D) -> void:
	_enter_section(2, body)


# Connect Section3Trigger's body_entered signal to this.
func _on_section_3_trigger_body_entered(body: Node2D) -> void:
	_enter_section(3, body)


func _tween_canvas(target_color: Color) -> void:
	if canvas_tween and canvas_tween.is_running():
		canvas_tween.kill()

	canvas_tween = create_tween()
	canvas_tween.tween_property(canvas, "color", target_color, 0.5)


func _update_counter() -> void:
	if lantern_counter_label:
		lantern_counter_label.text = "Lanterns: %d" % lanterns_collected


func _choose_ending() -> PackedScene:
	if lanterns_collected >= high_ending_min and high_ending_scene:
		return high_ending_scene

	if lanterns_collected >= middle_ending_min and middle_ending_scene:
		return middle_ending_scene

	if low_ending_scene:
		return low_ending_scene

	return cutscene_scene


func _on_cut_scene_trigger_body_entered(body: Node2D) -> void:
	if body != $Jingyue or cutscene_started:
		return

	var ending := _choose_ending()
	if ending == null:
		push_error("Assign an ending scene or Cutscene Scene in the Inspector.")
		return

	cutscene_started = true
	fade_player.play("fade in")
	await fade_player.animation_finished
	get_tree().change_scene_to_packed(ending)


func _on_checkpt_1_body_entered(body: Node2D) -> void:
	if body == $Jingyue:
		$Jingyue.spawn_position = $"Checkpt marker".global_position


func _on_checkpt_2_body_entered(body: Node2D) -> void:
	if body == $Jingyue:
		$Jingyue.spawn_position = $"checkpt marker 2".global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	_on_cut_scene_trigger_body_entered(body)
