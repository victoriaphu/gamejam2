extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0

var took_damage := false
var powered_up := false

@onready var sprite_2d: AnimatedSprite2D = $"Jingyue Sprite"
@onready var running_sound: AudioStreamPlayer = $"Running sound"
@onready var jumping_sound: AudioStreamPlayer = $"Jumping sound"
@onready var spawn_position: Vector2 = global_position
@onready var hurt: AudioStreamPlayer = $Hurt

func _physics_process(delta: float) -> void:
	if took_damage:
		return

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

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.name == "Obstacles":
			respawn()
			return

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


func respawn() -> void:
	took_damage = true
	running_sound.stop()
	jumping_sound.stop()
	hurt.play()
	velocity = Vector2.ZERO
	global_position = spawn_position
	sprite_2d.play("default")

	await get_tree().physics_frame

	for i in range(3):
		sprite_2d.modulate.a = 0.25
		await get_tree().create_timer(0.1).timeout
		sprite_2d.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout

	took_damage = false


func activate_power_up() -> void:
	powered_up = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
