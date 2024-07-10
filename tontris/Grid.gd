extends TileMap

var VIS_DIMENSIONS = Vector2i(10, 20)
var TOTAL_DIMENSIONS = Vector2i(10, 25)

var m_squares: Array[Tetromino.Kind] = []

@export var soft_lock_time: int = 5
@export var hard_lock_time: int = 5

func _init():
	m_squares.resize(TOTAL_DIMENSIONS.x * TOTAL_DIMENSIONS.y)
	m_squares.fill(Tetromino.Kind.NONE)

	# TODO: Remove this debug setting the board state
	m_squares[piece_coord_to_idx(Vector2i(1, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(2, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(3, 0))] = Tetromino.Kind.I
	m_squares[piece_coord_to_idx(Vector2i(4, 0))] = Tetromino.Kind.I


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().piece_moved.connect(_on_board_piece_moved)


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
	for i in range(VIS_DIMENSIONS.x * VIS_DIMENSIONS.y):
		set_cell(
			0,
			get_vis_coords_from_grid(get_grid_coords_from_idx(i)),
			0,
			tetr_kind_to_tile_vec[m_squares[i]]
		)


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_board_piece_moved(cur_piece: Tetromino.Piece) -> void:
	self.render_board()

	var cur_piece_coords = cur_piece.get_cells()
	for i in range(cur_piece_coords.size()):
		var coord := piece_coord_to_tilemap_coord(cur_piece_coords[i])
		if coord.y >= 0 && coord.y < VIS_DIMENSIONS.y:
			set_cell(
				0,
				coord,
				0,
				tetr_kind_to_tile_vec[cur_piece.get_kind()]
			)
