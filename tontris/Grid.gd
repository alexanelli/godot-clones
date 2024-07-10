extends TileMap

signal board_updated

var DIMENSIONS = Vector2i(10, 20)

var m_squares: Array[Tetromino.Kind] = []
var m_current_piece: Tetromino.Piece

@export var soft_lock_time: int = 5
@export var hard_lock_time: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_squares.resize(DIMENSIONS.x * DIMENSIONS.y)
	m_squares.fill(Tetromino.Kind.NONE)
	# TODO: Actually pull the first piece from the bag
	m_current_piece = Tetromino.Piece.new(Tetromino.TETR_INFO_J, Vector2i(4, 9))
	# TODO: Remove this debug setting the board state
	m_squares[piece_coord_to_idx(Vector2i(1, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(2, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(3, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(4, 0))] = Tetromino.Kind.I

	connect("board_updated", on_board_updated)

func color_cells(coords: Array[Vector2i], atlas_color: Vector2i):
	for coord in coords:
		set_cell(0, coord, 0, atlas_color)

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

func on_board_updated():
	for i in range(m_squares.size()):
		set_cell(
			0,
			get_grid_coords_from_idx(i),
			0,
			tetr_kind_to_tile_vec[m_squares[i]]
		)

	var cur_piece_coords = m_current_piece.get_cells()
	for i in range(cur_piece_coords.size()):
		var kind = m_current_piece.get_kind()
		set_cell(
			0,
			piece_coord_to_tilemap_coord(cur_piece_coords[i]),
			0,
			tetr_kind_to_tile_vec[m_current_piece.get_kind()]
		)


func get_grid_coords_from_idx(idx: int) -> Vector2i:
	var row = (DIMENSIONS.y - 1) - (idx / DIMENSIONS.x)
	var col = idx % DIMENSIONS.x
	return Vector2i(col, row)

func piece_coord_to_tilemap_coord(p_coord: Vector2i) -> Vector2i:
	return Vector2i(p_coord.x, (DIMENSIONS.y - 1) - p_coord.y)

func piece_coord_to_idx(p_coord: Vector2i) -> int:
	return (p_coord.y * DIMENSIONS.x) + p_coord.x

#TODO: Remove me
var updated_board = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO: Remove me
	if !updated_board:
		emit_signal("board_updated")
		updated_board = true
	pass
