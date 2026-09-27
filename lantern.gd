extends AnimatedSprite2D

var starting_y: float
var time := 0.0

func _ready() -> void:
	starting_y = position.y

func _process(delta: float) -> void:
	time += delta
	position.y = starting_y + sin(time * 2.0) * 4.0


func _on_area_2d_body_entered(body: Node2D) -> void:
		if body is CharacterBody2D:
			queue_free()
