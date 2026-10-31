extends Node2D

const CELL_SIZE = 48

const MAZE_MAP = [
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
	create_wall_collisions()
	create_exit()

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

	# Very small detection area
	shape.size = Vector2(2, 2)
	collision.shape = shape

	exit_area.add_child(collision)

	# Find the exact exit cell from the maze map
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
		body.velocity = Vector2.ZERO
		body.set_physics_process(false)

		var win_label = Label.new()
		win_label.text = "YOU WIN!"
		win_label.position = Vector2(450, 280)
		win_label.add_theme_font_size_override("font_size", 48)
		win_label.modulate = Color("#A78BFA")

		add_child(win_label)

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
				draw_rect(rect, WALL_COLOR)
			else:
				draw_rect(rect, FLOOR_COLOR)

			if cell == "S":
				draw_rect(rect.grow(-10), START_COLOR)

			elif cell == "E":
				draw_rect(rect.grow(-10), EXIT_COLOR)
