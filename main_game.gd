extends Node
@export var guide_lights: Array[PointLight2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"fade transition/ColorRect/AnimationPlayer".play("fade out")


func _on_lantern_picked_up() -> void:
	var starting_color: Color = $CanvasModulate.color

	for i in range(guide_lights.size()):
		await get_tree().create_timer(0.6).timeout

		var light := guide_lights[i]
		if is_instance_valid(light):
			light.enabled = true

		var progress := float(i + 1) / guide_lights.size()
		var next_color := starting_color.lerp(Color.WHITE, progress)
		create_tween().tween_property($CanvasModulate, "color", next_color, 0.5)
