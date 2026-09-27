extends AnimatedSprite2D

signal picked_up

var starting_y: float
var time := 0.0
@onready var pick_up: AudioStreamPlayer = $PickUp

func _ready() -> void:
	starting_y = position.y

func _process(delta: float) -> void:
	time += delta
	position.y = starting_y + sin(time * 2.0) * 4.0


var collected := false  # Add this near your other variables.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D or collected:
		return

	collected = true
	picked_up.emit()
	$Area2D.set_deferred("monitoring", false)
	hide()
	pick_up.play()
	await pick_up.finished
	queue_free()
		
