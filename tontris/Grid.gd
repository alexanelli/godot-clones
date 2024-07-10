extends TileMap

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

	m_current_piece = Tetromino.Piece.new(
		Tetromino.kind_to_info(get_parent().get_node("Queue").pop()),
		Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
	)
	#m_current_piece = Tetromino.Piece.new(Tetromino.TETR_INFO_J, Vector2i(4, 9))
	# TODO: Remove this debug setting the board state
	m_squares[piece_coord_to_idx(Vector2i(1, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(2, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(3, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(4, 0))] = Tetromino.Kind.I

	render_board()

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

func render_board() -> void:
	for i in range(m_squares.size()):
		set_cell(
			0,
			get_grid_coords_from_idx(i),
			0,
			tetr_kind_to_tile_vec[m_squares[i]]
		)

	var cur_piece_coords = m_current_piece.get_cells()
	for i in range(cur_piece_coords.size()):
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
var m_updated_board = false

var ROTATE_TIME: float = 1.0
var m_time_elapsed_since_rotate: float = 0.0
var m_rotations: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var updated := false

	m_time_elapsed_since_rotate += delta

	while m_time_elapsed_since_rotate > 1.0:
		m_time_elapsed_since_rotate -= ROTATE_TIME
		m_current_piece.rotate_left()
		m_current_piece.accept_rotation()
		m_rotations += 1
		if m_rotations == 4:
			m_current_piece = Tetromino.Piece.new(
				Tetromino.kind_to_info(get_parent().get_node("Queue").pop()),
				Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
			)
			m_rotations -= 4

		updated = true

	if updated:
		render_board()
