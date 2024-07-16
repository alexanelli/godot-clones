extends Node2D

signal piece_moved(piece: Tetromino.Piece)

var m_current_piece: Tetromino.Piece
var m_hold_state: ButtonHold

@export var initial_hold_wait_msec = 250
@export var hold_repeat_msec = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_current_piece = Tetromino.Piece.new(
		Tetromino.kind_to_info(get_node("Queue").queue_pop()),
	)

	m_hold_state = ButtonHold.new(initial_hold_wait_msec, hold_repeat_msec)
	piece_moved.emit(m_current_piece)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var repeats := m_hold_state.get_repeats()
	for _i in repeats:
		match m_hold_state.currently_holding():
			ButtonHold.HoldType.SHIFT_LEFT:
				m_current_piece.shift_left()
			ButtonHold.HoldType.SHIFT_RIGHT:
				m_current_piece.shift_right()
			ButtonHold.HoldType.SOFT_DROP:
				m_current_piece.shift_down()

	if repeats > 0:
		piece_moved.emit(m_current_piece)


func _input(event: InputEvent) -> void:
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

	if event.is_action_pressed("Rotate_Left"):
		m_current_piece.rotate_left()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	if event.is_action_pressed("Rotate_Right"):
		m_current_piece.rotate_right()
		m_current_piece.accept_rotation()
		piece_moved.emit(m_current_piece)

	handle_shift(event)

func handle_shift(event: InputEvent) -> void:
	var shift_hold: ButtonHold.HoldType = ButtonHold.HoldType.NONE

	if event.is_released():
		shift_hold = handle_shift_released(event)
	else:
		# Determine highest priority held shift button
		if event.is_action_pressed("Shift_Left", true):
			shift_hold = ButtonHold.HoldType.SHIFT_LEFT

		if event.is_action_pressed("Shift_Right", true):
			shift_hold = ButtonHold.HoldType.SHIFT_RIGHT

		if event.is_action_pressed("Soft_Drop", true):
			shift_hold = ButtonHold.HoldType.SOFT_DROP

	if m_hold_state.currently_holding() != ButtonHold.HoldType.NONE:
		return

	if shift_hold != ButtonHold.HoldType.NONE:
		match shift_hold:
			ButtonHold.HoldType.SHIFT_LEFT:
				m_current_piece.shift_left()
			ButtonHold.HoldType.SHIFT_RIGHT:
				m_current_piece.shift_right()
			ButtonHold.HoldType.SOFT_DROP:
				m_current_piece.shift_down()

		m_hold_state.begin_hold(shift_hold)
		piece_moved.emit(m_current_piece)

func handle_shift_released(event: InputEvent) -> ButtonHold.HoldType:
	if event.is_action_released("Shift_Left"):
		m_hold_state.release(ButtonHold.HoldType.SHIFT_LEFT)

	if event.is_action_released("Shift_Right"):
		m_hold_state.release(ButtonHold.HoldType.SHIFT_RIGHT)

	if event.is_action_released("Soft_Drop"):
		m_hold_state.release(ButtonHold.HoldType.SOFT_DROP)

	if Input.is_action_pressed("Soft_Drop"):
		return ButtonHold.HoldType.SOFT_DROP

	if Input.is_action_pressed("Shift_Right"):
		return ButtonHold.HoldType.SHIFT_RIGHT

	if Input.is_action_pressed("Shift_Left"):
		return ButtonHold.HoldType.SHIFT_LEFT

	return ButtonHold.HoldType.NONE