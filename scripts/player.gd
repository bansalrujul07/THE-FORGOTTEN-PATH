extends CharacterBody2D

const SPEED = 200.0

func _ready():
	# Place the player at the maze starting position
	position = Vector2(288, 132)
	queue_redraw()


func _physics_process(delta):
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * SPEED
	move_and_slide()


func _draw():
	# Outer glow
	draw_circle(Vector2.ZERO, 17, Color("#176B91"))

	# Main player body
	draw_circle(Vector2.ZERO, 12, Color("#39D5FF"))

	# Small bright center
	draw_circle(Vector2.ZERO, 5, Color("#D5FAFF"))
