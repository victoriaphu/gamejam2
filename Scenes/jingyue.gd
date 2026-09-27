extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0

@onready var sprite_2d: AnimatedSprite2D = $"Jingyue Sprite"
@onready var running_sound: AudioStreamPlayer = $"Running sound"
@onready var jumping_sound: AudioStreamPlayer = $"Jumping sound"

var powered_up := false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumping_sound.play()

	var direction := Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 40)

	move_and_slide()

	var next_animation: StringName
	if not is_on_floor():
		next_animation = &"Jumping"
	elif absf(velocity.x) > 1:
		next_animation = &"Running"
	else:
		next_animation = &"default"

	if sprite_2d.animation != next_animation:
		sprite_2d.play(next_animation)

	if direction != 0 and is_on_floor():
		if not running_sound.playing:
			running_sound.play()
	else:
		running_sound.stop()


func activate_power_up() -> void:
	powered_up = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
