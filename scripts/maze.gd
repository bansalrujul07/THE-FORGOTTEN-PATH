extends Node2D

const CELL_SIZE = 48
var wall_alpha = 1.0
var level_manager: Node
var echo_active = false
var echo_position = Vector2.ZERO
var echo_time_left = 0.0
var echo_charges = 3
var echo_label: Label
var time_left = 60.0
var timer_label: Label
var game_over = false
var game_won = false

const ECHO_RADIUS = 180.0
const ECHO_DURATION = 1.5

var MAZE_MAP = [
	"###############",
	"#S....#.......#",
	"#.##..#.#####.#",
	"#....##.....#.#",
	"####.#####..#.#",
	"#....#...#..#.#",
	"#.##.#.#.#.##.#",
	"#....#.#......#",
	"#.####.######.#",
	"#.............E#",
	"###############"
]

const WALL_COLOR = Color("#39415F")
const FLOOR_COLOR = Color("#20243B")
const START_COLOR = Color("#39D5FF")
const EXIT_COLOR = Color("#A78BFA")

func _ready():
	# Get the current level settings
	level_manager = LevelManager
	var level_data = level_manager.get_current_level_data()

	# Load the selected level's maze
	MAZE_MAP = level_data["maze_map"]

	# Load difficulty settings
	time_left = level_data["time_limit"]
	echo_charges = level_data["echo_charges"]

	# Create the maze using the selected map
	create_wall_collisions()
	create_exit()
	# Create UI
	create_echo_ui()
	create_timer_ui()
	create_level_ui()

	# Update UI with level settings
	timer_label.text = "TIME: " + str(ceil(time_left))
	echo_label.text = "ECHO: " + str(echo_charges)

	# Keep the maze visible for 3 seconds
	await get_tree().create_timer(3.0).timeout

	# Fade the walls over 2 seconds
	var tween = create_tween()
	tween.tween_property(self, "wall_alpha", 0.0, 2.0)

	await tween.finished

func activate_echo(player_position: Vector2):
	if echo_charges <= 0:
		return
	if wall_alpha > 0.0:
		return
	if echo_active:
		return
	echo_charges -= 1
	echo_active = true
	echo_position = player_position
	echo_time_left = ECHO_DURATION

	echo_label.text = "ECHO: " + str(echo_charges)
	queue_redraw()
	
func create_echo_ui():
	echo_label = Label.new()
	echo_label.text = "ECHO: 3"
	echo_label.position = Vector2(40, 20)

	echo_label.add_theme_font_size_override("font_size", 24)
	echo_label.add_theme_color_override(
		"font_color",
		Color("#39D5FF")
	)

	add_child(echo_label)

func create_timer_ui():
	timer_label = Label.new()
	timer_label.text = "TIME: 60"
	timer_label.position = Vector2(950, 20)

	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override(
		"font_color",
		Color("#A78BFA")
	)

	add_child(timer_label)

func create_level_ui():
	var level_label = Label.new()

	level_label.text = level_manager.get_current_level_data()["name"]
	level_label.position = Vector2(400, 20)
	level_label.size = Vector2(350, 40)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.add_theme_color_override(
		"font_color",
		Color("#E0D7FF")
	)
	add_child(level_label)

func show_game_over():
	var game_over_label = Label.new()
	game_over_label.text = "TIME'S UP!\nGAME OVER"

	game_over_label.position = Vector2(390, 250)
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override(
		"font_color",
		Color("#FF5C7A")
	)
	add_child(game_over_label)

func show_level_completed():
	var completed_label = Label.new()
	completed_label.text = "LEVEL COMPLETED!\n" + level_manager.get_current_level_data()["name"]

	completed_label.position = Vector2(350, 220)
	completed_label.add_theme_font_size_override("font_size", 36)
	completed_label.add_theme_color_override(
		"font_color",
		Color("#39D5FF")
	)

	add_child(completed_label)

	if level_manager.has_next_level():
		var next_button = Button.new()
		next_button.text = "NEXT LEVEL"
		next_button.position = Vector2(480, 360)
		next_button.size = Vector2(190, 55)

		next_button.pressed.connect(_on_next_level_pressed)
		add_child(next_button)
	else:
		var final_label = Label.new()
		final_label.text = "YOU COMPLETED ALL LEVELS!"
		final_label.position = Vector2(390, 370)
		final_label.add_theme_font_size_override("font_size", 24)
		add_child(final_label)

func _on_next_level_pressed():
	if level_manager.advance_level():
		get_tree().reload_current_scene()

	# Stop player movement
	var player = get_parent().get_node("Player")
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)

func create_wall_collisions():
	var rows = MAZE_MAP.size()
	var cols = MAZE_MAP[0].length()

	var offset_x = (1152 - cols * CELL_SIZE) / 2
	var offset_y = (648 - rows * CELL_SIZE) / 2

	for y in range(rows):
		for x in range(cols):
			if MAZE_MAP[y][x] == "#":
				var wall = StaticBody2D.new()
				var collision = CollisionShape2D.new()

				var shape = RectangleShape2D.new()
				shape.size = Vector2(CELL_SIZE, CELL_SIZE)

				collision.shape = shape
				wall.add_child(collision)

				wall.position = Vector2(
					offset_x + x * CELL_SIZE + CELL_SIZE / 2,
					offset_y + y * CELL_SIZE + CELL_SIZE / 2
				)

				add_child(wall)


func create_exit():
	var exit_area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()

	shape.size = Vector2(2, 2)
	collision.shape = shape

	exit_area.add_child(collision)

	# Find the exit cell from the maze map
	for y in range(MAZE_MAP.size()):
		var x = MAZE_MAP[y].find("E")

		if x != -1:
			var offset_x = (1152 - MAZE_MAP[0].length() * CELL_SIZE) / 2
			var offset_y = (648 - MAZE_MAP.size() * CELL_SIZE) / 2

			exit_area.position = Vector2(
				offset_x + x * CELL_SIZE + CELL_SIZE / 2,
				offset_y + y * CELL_SIZE + CELL_SIZE / 2
			)

			break

	exit_area.body_entered.connect(_on_exit_body_entered)
	add_child(exit_area)


func _on_exit_body_entered(body):
	if body is CharacterBody2D:
		if game_over or game_won:
			return
		game_won = true
		
		body.velocity = Vector2.ZERO
		body.set_physics_process(false)
		show_level_completed()
		print("Congratulations! You completed the maze!")

func _draw():
	var rows = MAZE_MAP.size()
	var cols = MAZE_MAP[0].length()

	var maze_width = cols * CELL_SIZE
	var maze_height = rows * CELL_SIZE

	var offset_x = (1152 - maze_width) / 2
	var offset_y = (648 - maze_height) / 2

	for y in range(rows):
		for x in range(cols):
			var cell = MAZE_MAP[y][x]

			var position = Vector2(
				offset_x + x * CELL_SIZE,
				offset_y + y * CELL_SIZE
			)

			var rect = Rect2(
				position,
				Vector2(CELL_SIZE, CELL_SIZE)
			)

			if cell == "#":
				var wall_center = position + Vector2(
					CELL_SIZE / 2,
					CELL_SIZE / 2
				)

				var distance = wall_center.distance_to(echo_position)

				if echo_active and distance <= ECHO_RADIUS:
					var glow_color = Color("#39D5FF")

					# Top boundary
					if y == 0 or MAZE_MAP[y - 1][x] != "#":
						draw_line(
							position,
							position + Vector2(CELL_SIZE, 0),
							glow_color,
							2.5
						)

					# Bottom boundary
					if y == rows - 1 or MAZE_MAP[y + 1][x] != "#":
						draw_line(
							position + Vector2(0, CELL_SIZE),
							position + Vector2(CELL_SIZE, CELL_SIZE),
							glow_color,
							2.5
						)

					# Left boundary
					if x == 0 or MAZE_MAP[y][x - 1] != "#":
						draw_line(
							position,
							position + Vector2(0, CELL_SIZE),
							glow_color,
							2.5
						)

					# Right boundary
					if x == cols - 1 or MAZE_MAP[y][x + 1] != "#":
						draw_line(
							position + Vector2(CELL_SIZE, 0),
							position + Vector2(CELL_SIZE, CELL_SIZE),
							glow_color,
							2.5
						)

				elif wall_alpha > 0.0:
					var faded_wall_color = WALL_COLOR
					faded_wall_color.a = wall_alpha
					draw_rect(rect, faded_wall_color)

			elif wall_alpha >= 1.0:
				draw_rect(rect, FLOOR_COLOR)

			if cell == "S":
				draw_rect(rect.grow(-10), START_COLOR)
			elif cell == "E":
				draw_rect(rect.grow(-10), EXIT_COLOR)

func _process(delta):
	if game_over or game_won:
		return

	# Start countdown only after the maze disappears
	if wall_alpha <= 0.0:
		time_left -= delta
		timer_label.text = "TIME: " + str(ceil(time_left))

		if time_left <= 0:
			time_left = 0
			game_over = true
			show_game_over()

	if wall_alpha < 1.0:
		queue_redraw()

	if echo_active:
		echo_time_left -= delta

		if echo_time_left <= 0:
			echo_active = false

		queue_redraw()
