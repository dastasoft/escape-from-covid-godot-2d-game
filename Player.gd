extends Area2D

signal hit

export var speed = 400.0
var screen_size = Vector2.ZERO
var isDead = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	isDead = false

func _process(delta):
	var direction = Vector2.ZERO
	
	if Input.get_accelerometer().x < 0:
		direction.x -= 1
	if Input.get_accelerometer().x > 0:
		direction.x += 1
	if Input.get_accelerometer().y > 0:
		direction.y -= 1
	if Input.get_accelerometer().y < 0:
		direction.y += 1
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if direction.length() > 0:
		direction = direction.normalized()
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += direction * speed * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if direction.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_h = direction.x < 0
		$AnimatedSprite.flip_v = false
	elif direction.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = direction.y > 0


func start(new_position):
	position = new_position
	isDead = false
	show()
	$CollisionShape2D.disabled = false

func death_stop():
	get_tree().paused = true
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false

func _on_Player_body_entered(_body):
	if !isDead:
		isDead = true
		
		get_owner().get_node("Camera2D").add_trauma(1)
		
		yield(death_stop(), "completed")
		
		Engine.time_scale = 0.5
		
		hide()
		$CollisionShape2D.set_deferred("disable", true)
		emit_signal("hit")
