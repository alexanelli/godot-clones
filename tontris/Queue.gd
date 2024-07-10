extends VBoxContainer

class Bag:
	const SIZE = 7

	var m_pieces: Array[Tetromino.Kind] = [
		Tetromino.Kind.I,
		Tetromino.Kind.T,
		Tetromino.Kind.O,
		Tetromino.Kind.Z,
		Tetromino.Kind.S,
		Tetromino.Kind.J,
		Tetromino.Kind.L
	]

	func shuffle():
		m_pieces.shuffle()

	func piece_at_pos(pos: int) -> Tetromino.Kind:
		assert(pos < SIZE)
		return m_pieces[pos]

# Implemented as two bags stapled together. We don't actually take the pieces
# out of the bag, we just look at the piece in our current bag, and increment
# our position, wrapping around if we get to the end of the queue.
# We calculate our current bag using MATHS (division). We don't generate new
# bag objects to continue the queue, we just shuffle it when it's out of view,
# and wrap the position back around to it at the relevant time.

const NUM_BAGS = 2
var m_piece_queue: Array[Bag] = []
var m_queue_position: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _init() -> void:
	m_piece_queue.resize(NUM_BAGS)
	for i in range(NUM_BAGS):
		m_piece_queue[i] = Bag.new()
		m_piece_queue[i].shuffle()


func pop() -> Tetromino.Kind:
	@warning_ignore("integer_division")
	var bag: int = m_queue_position / Bag.SIZE
	var bag_pos: int = m_queue_position % Bag.SIZE

	var ret: Tetromino.Kind = m_piece_queue[bag].piece_at_pos(bag_pos)
	m_queue_position = get_wrapped_position_after_adding(1)

	# If we've just taken the last piece out of a bag, shuffle the bag we just
	# finished
	if m_queue_position % Bag.SIZE == 0:
		@warning_ignore("integer_division")
		var idx_to_shuffle = get_wrapped_position_after_adding(7) / Bag.SIZE
		m_piece_queue[idx_to_shuffle].shuffle()

	return ret

func get_wrapped_position_after_adding(add: int) -> int:
	return (m_queue_position + add) % (Bag.SIZE * NUM_BAGS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
