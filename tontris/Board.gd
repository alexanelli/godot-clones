extends Node2D

signal piece_moved(piece: Tetromino.Piece)

var m_current_piece: Tetromino.Piece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_current_piece = Tetromino.Piece.new(
		Tetromino.kind_to_info(get_node("Queue").queue_pop()),
		Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
	)

	piece_moved.emit(m_current_piece)

var ROTATE_TIME: float = 1.0
var m_time_elapsed_since_rotate: float = 0.0
var m_rotations: int = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# var updated := false

	# m_time_elapsed_since_rotate += delta

	# while m_time_elapsed_since_rotate > 1.0:
	# 	m_time_elapsed_since_rotate -= ROTATE_TIME
	# 	m_current_piece.rotate_left()
	# 	m_current_piece.accept_rotation()
	# 	m_rotations += 1
	# 	if m_rotations == 4:
	# 		m_current_piece = Tetromino.Piece.new(
	# 			Tetromino.kind_to_info(get_node("Queue").pop()),
	# 			Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
	# 		)
	# 		m_rotations -= 4

	# 	updated = true

	# if updated:
	# 	piece_moved.emit(m_current_piece)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate_Left"):
		m_current_piece.rotate_left()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	if event.is_action_pressed("Shift_Left"):
		m_current_piece.shift_left()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	if event.is_action_pressed("Rotate_Right"):
		m_current_piece.rotate_right()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	if event.is_action_pressed("Shift_Right"):
		m_current_piece.shift_right()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	if event.is_action_pressed("Soft_Drop"):
		m_current_piece.shift_down()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	if event.is_action_pressed("Hold"):
		# swap the kind of the current piece with what's in swap
		var swap_kind : Tetromino.Kind = $"Hold".swap(m_current_piece.get_kind())

		# if we swapped for NONE, grab the next piece from the queue
		if swap_kind == Tetromino.Kind.NONE:
			swap_kind = $"Queue".queue_pop()
		
		m_current_piece = Tetromino.Piece.new(
			Tetromino.kind_to_info(swap_kind),
			Vector2i(4, 9), #the location can be removed when not testing, it defaults to the proper position
		)
		piece_moved.emit(m_current_piece)

