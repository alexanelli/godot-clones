extends Node2D

var m_current_piece: Tetromino.Piece
var m_hold_state: ButtonHold
var m_shift_down_timer: Timer
var m_hold_available: bool

@export var initial_hold_wait_msec: int = 250
@export var hold_repeat_msec: int = 100
@export var piece_falling_speed = 1
@export var piece_lock_delay_ms: int = 1000

var m_accrued_lock_time: float = 0.0
var m_locking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_shift_down_timer = Timer.new()
	add_child(m_shift_down_timer)
	m_shift_down_timer.wait_time = piece_falling_speed
	m_shift_down_timer.start()
	m_shift_down_timer.timeout.connect(_on_shift_down_timer)

	m_hold_state = ButtonHold.new(initial_hold_wait_msec, hold_repeat_msec)
	create_new_current_piece($"Queue".queue_pop())

func _on_shift_down_timer() -> void:
	#$"Grid".try_move(m_current_piece.shift_down)
	try_shift(ButtonHold.HoldType.SOFT_DROP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if m_locking:
		m_accrued_lock_time += delta
		if m_accrued_lock_time >= (piece_lock_delay_ms/1000.0):
			emplace_current_piece()

	var repeats := m_hold_state.get_repeats()
	for _i in repeats:
		try_shift(m_hold_state.currently_holding())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Hold"):
		handle_hold_event()
		return

	if event.is_action_pressed("Rotate_Left"):
		try_rotate(m_current_piece.rotate_left)
		return

	if event.is_action_pressed("Rotate_Right"):
		try_rotate(m_current_piece.rotate_right)
		return

	if event.is_action_pressed("Hard_Drop"):
		var drop_position: Vector2i = $"Grid".get_drop_position(m_current_piece)
		m_current_piece.set_position(drop_position)
		emplace_current_piece()

	handle_shift_event(event)

func handle_hold_event():
	if !m_hold_available:
		return

	# swap the kind of the current piece with what's in swap
	var swap_kind : Tetromino.Kind = $"Hold".swap(m_current_piece.get_kind())

	# if we swapped for NONE, grab the next piece from the queue
	if swap_kind == Tetromino.Kind.NONE:
		swap_kind = $"Queue".queue_pop()

	create_new_current_piece(swap_kind)
	m_hold_available = false

func create_new_current_piece(kind: Tetromino.Kind) -> void:
	m_current_piece = Tetromino.Piece.new(
		Tetromino.kind_to_info(kind),
	)

	m_shift_down_timer.start()
	m_accrued_lock_time = 0.0
	m_locking = false
	m_hold_available = true
	$"Grid".update_current_piece(m_current_piece)


func handle_shift_event(event: InputEvent) -> void:
	var shift_hold: ButtonHold.HoldType = ButtonHold.HoldType.NONE

	if event.is_released():
		shift_hold = handle_shift_released_event(event)
	else:
		shift_hold = handle_shift_pressed_event_hold_priority(event)

	if m_hold_state.currently_holding() != ButtonHold.HoldType.NONE:
		return

	if shift_hold != ButtonHold.HoldType.NONE:
		try_shift(shift_hold)
		m_hold_state.begin_hold(shift_hold)

func handle_shift_pressed_event_hold_priority(event: InputEvent) -> ButtonHold.HoldType:
	if event.is_action_pressed("Soft_Drop", true):
		return ButtonHold.HoldType.SOFT_DROP

	if event.is_action_pressed("Shift_Right", true):
		return ButtonHold.HoldType.SHIFT_RIGHT

	if event.is_action_pressed("Shift_Left", true):
		return ButtonHold.HoldType.SHIFT_LEFT

	return ButtonHold.HoldType.NONE


func handle_shift_released_event(event: InputEvent) -> ButtonHold.HoldType:
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

# Using HoldType for this seems very hacky
func try_shift(t: ButtonHold.HoldType) -> bool:
	if t == ButtonHold.HoldType.NONE:
		return false

	var shift_fn: Callable
	match t:
		ButtonHold.HoldType.SHIFT_LEFT:
			shift_fn = m_current_piece.shift_left
		ButtonHold.HoldType.SHIFT_RIGHT:
			shift_fn = m_current_piece.shift_right
		ButtonHold.HoldType.SOFT_DROP:
			shift_fn = m_current_piece.shift_down

	var current_pos := m_current_piece.get_position()
	shift_fn.call()

	if !$"Grid".in_valid_position(m_current_piece):
		m_current_piece.set_position(current_pos)
		return false

	if t == ButtonHold.HoldType.SOFT_DROP:
		m_shift_down_timer.start()

	m_locking = is_current_piece_bottomed_out()
	$"Grid".update_current_piece(m_current_piece)
	return true

func emplace_current_piece() -> void:
	$"Grid".lock_piece(m_current_piece)
	$"Grid".check_and_clear_lines() #returns number of lines cleared, can be used for scoring later
	create_new_current_piece($"Queue".queue_pop())
	return

func is_current_piece_bottomed_out() -> bool:
	var current_pos: Vector2i = m_current_piece.get_position()
	m_current_piece.set_position(Vector2i(current_pos.x, current_pos.y - 1))
	var bottomed_out: bool = !$"Grid".in_valid_position(m_current_piece)
	m_current_piece.set_position(current_pos)
	return bottomed_out

func try_rotate(rotate_fn: Callable) -> bool:
	rotate_fn.call()
	if $"Grid".in_valid_position(m_current_piece):
		m_current_piece.accept_rotation()
		$"Grid".update_current_piece(m_current_piece)
		m_locking = is_current_piece_bottomed_out()
		return true

	while m_current_piece.advance_current_offset():
		if $"Grid".in_valid_position(m_current_piece):
			m_current_piece.accept_rotation()
			$"Grid".update_current_piece(m_current_piece)
			m_locking = is_current_piece_bottomed_out()
			return true

	m_current_piece.reject_rotation()
	return false
