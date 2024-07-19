extends TileMap

enum Layer {
	Base,
	Shadow,
	Stack,
	Piece,
}

var VIS_DIMENSIONS = Vector2i(10, 20)
var TOTAL_DIMENSIONS = Vector2i(10, 25)

var m_squares: Array[Tetromino.Kind] = []

@export var soft_lock_time: int = 5
@export var hard_lock_time: int = 5

func _init():
	m_squares.resize(TOTAL_DIMENSIONS.x * TOTAL_DIMENSIONS.y)
	m_squares.fill(Tetromino.Kind.NONE)

	# TODO: Remove this debug setting the board state
	# m_squares[piece_coord_to_idx(Vector2i(1, 0))] = Tetromino.Kind.I
	# m_squares[piece_coord_to_idx(Vector2i(2, 0))] = Tetromino.Kind.I
	# m_squares[piece_coord_to_idx(Vector2i(3, 0))] = Tetromino.Kind.I
	# m_squares[piece_coord_to_idx(Vector2i(4, 0))] = Tetromino.Kind.I


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

var tetr_kind_to_tile_vec: Array[Vector2i] = [
	Vector2i(7, 0),
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(3, 0),
	Vector2i(4, 0),
	Vector2i(5, 0),
	Vector2i(6, 0)
]

# TODO: we'll want some variant of this once we're emplacing onto the piece
# stack, but it will affect layer 2
func render_board() -> void:
	for i in range(VIS_DIMENSIONS.x * VIS_DIMENSIONS.y):
		set_cell(
			0,
			get_vis_coords_from_grid(get_grid_coords_from_idx(i)),
			0,
			tetr_kind_to_tile_vec[m_squares[i]]
		)

func draw_piece(piece: Tetromino.Piece, layer: int) -> void:
	var cells := piece.get_cells()
	for i in cells.size():
		set_cell(
			layer,
			piece_coord_to_tilemap_coord(cells[i]),
			0,
			tetr_kind_to_tile_vec[piece.get_kind()],
		)

func lock_piece(piece: Tetromino.Piece) -> void:
	var cells := piece.get_cells()
	for i in cells.size():
		m_squares[piece_coord_to_idx(cells[i])] = piece.get_kind()

	draw_piece(piece, Layer.Stack)

func update_current_piece(piece: Tetromino.Piece) -> void:
	clear_layer(Layer.Piece)
	clear_layer(Layer.Shadow)
	draw_piece(piece, Layer.Piece)

	var shadow_position := get_drop_position(piece)
	var current_position := piece.get_position()
	piece.set_position(shadow_position)
	draw_piece(piece, Layer.Shadow)
	piece.set_position(current_position)

func get_drop_position(piece: Tetromino.Piece) -> Vector2i:
	# Start at bottom of board and shift piece up until it is in a valid position,
	# then use that as the position for the drop shadow
	var ret: Vector2i = piece.get_position()
	var current_position := piece.get_position()
	for y in range(current_position.y, -1, -1):
		piece.set_position(Vector2i(current_position.x, y-1))
		if !in_valid_position(piece):
			ret = Vector2i(current_position.x, y)
			break

	# Put piece back in its actual position once we're done calcing shadow
	piece.set_position(current_position)
	return ret

func in_valid_position(piece: Tetromino.Piece) -> bool:
	var cells := piece.get_cells()

	for i in cells.size():
		if !(cells[i].x >= 0 && cells[i].x < TOTAL_DIMENSIONS.x &&
			cells[i].y >= 0 && cells[i].y < TOTAL_DIMENSIONS.y &&
			m_squares[piece_coord_to_idx(cells[i])] == Tetromino.Kind.NONE):

			return false

	return true

func get_grid_coords_from_idx(idx: int) -> Vector2i:
	var row = (TOTAL_DIMENSIONS.y - 1) - (idx / TOTAL_DIMENSIONS.x)
	var col = idx % TOTAL_DIMENSIONS.x
	return Vector2i(col, row)

func get_vis_coords_from_grid(coord: Vector2i) -> Vector2i:
	return Vector2i(coord.x, coord.y-(TOTAL_DIMENSIONS.y - VIS_DIMENSIONS.y))

func piece_coord_to_tilemap_coord(p_coord: Vector2i) -> Vector2i:
	return Vector2i(p_coord.x, (VIS_DIMENSIONS.y - 1) - p_coord.y)

func piece_coord_to_idx(p_coord: Vector2i) -> int:
	return (p_coord.y * TOTAL_DIMENSIONS.x) + p_coord.x

func try_move(piece_shift: Callable, _if_legal: Callable, _if_illegal: Callable):
	piece_shift.call()

func place(cur_piece: Tetromino.Piece) -> void:
	for cell in cur_piece.get_cells():
		m_squares[piece_coord_to_idx(cell)] = cur_piece.Kind

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
