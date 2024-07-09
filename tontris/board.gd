extends TileMap

# use dis https://tetris.wiki/Super_Rotation_System


@export var soft_lock_time = 5
@export var hard_lock_time = 5

const BAG_SIZE = 7

# in order of the tilemap colors (cyan, purple, yellow, red, green, orange, blue, grey)
enum Tetromino {I, T, O, Z, S, J, L, NONE}

var piece_queue = []

var current_piece_pos = 0

func fill_piece_queue(startingIndex, bag):
	for i in range(BAG_SIZE):
		piece_queue[(startingIndex + i) % piece_queue.size()] = bag[i]

func make_bag() -> Array[Tetromino]:
	var ret: Array[Tetromino] = [
		Tetromino.I,
		Tetromino.T,
		Tetromino.O,
		Tetromino.Z,
		Tetromino.S,
		Tetromino.J,
		Tetromino.L
	]
	
	ret.shuffle()
	return ret

func spawn_tetromino(tetronimo: Tetromino):
	const LAYER=0
	const SOURCE = 0 # got this by hovering over the tiles in the tileset viewer
	var color = Vector2i(tetronimo, 0)

	match tetronimo:
		Tetromino.I:
			set_cell(LAYER, Vector2i(3, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(6, 1), SOURCE, color)
		Tetromino.T:
			set_cell(LAYER, Vector2i(5, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(6, 1), SOURCE, color)
		Tetromino.O:
			set_cell(LAYER, Vector2i(4, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 1), SOURCE, color)
		Tetromino.Z:
			set_cell(LAYER, Vector2i(3, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 1), SOURCE, color)
		Tetromino.S:
			set_cell(LAYER, Vector2i(4, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(3, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 1), SOURCE, color)
		Tetromino.J:
			set_cell(LAYER, Vector2i(5, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 2), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 2), SOURCE, color)
		Tetromino.L:
			set_cell(LAYER, Vector2i(4, 0), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 1), SOURCE, color)
			set_cell(LAYER, Vector2i(4, 2), SOURCE, color)
			set_cell(LAYER, Vector2i(5, 2), SOURCE, color)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	piece_queue.resize(BAG_SIZE * 2)
	fill_piece_queue(0, make_bag())
	fill_piece_queue(7, make_bag())
	print(piece_queue)
	spawn_tetromino(Tetromino.L)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
