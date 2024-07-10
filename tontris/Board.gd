extends Node2D

signal piece_moved(piece: Tetromino.Piece)

var m_current_piece: Tetromino.Piece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_current_piece = Tetromino.Piece.new(
		Tetromino.kind_to_info(get_node("Queue").pop()),
		Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
	)

	piece_moved.emit(m_current_piece)

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
				Tetromino.kind_to_info(get_node("Queue").pop()),
				Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
			)
			m_rotations -= 4

		updated = true

	if updated:
		piece_moved.emit(m_current_piece)
