extends Resource

class_name Tetromino

"""
# Spawning an I Tetromino:
# Replace the TETR_INFO object with the appropriate block info for other block
# types
# Its default initial position is the (4, 22), as per tetris rules, but you
# can set the `pos` param to initially emplace it whereever you want.
piece = Piece.new(TETR_INFO_I)

# Get its position as the list of the cells it occupies!
piece.get_cells()

# Shifting it down...
# See shift_left, shift_right, and shift_up for other directions...
piece.shift_down()

# Getting its position now would reflect that it has been shifted

# Rotate it clockwise.
# See shift_left for counterclockwise...
piece.rotate_right()

# Getting its position now would reflect that it has been rotated

# When a piece is rotated, it may not be in a legal position. You may have to
# deny the request to rotate, but before doing so, there are a series of test
# offsets to check for validity in sequence before denying the rotation. After
# rotation, the piece is already on the first test offset. You can have the piece
# shift to its next test offset with:
piece.advance_current_offset()

# ^ If this returns true, there was an offset to try, and it is now reflected
# in the piece's current position. If it was false, then you are out of tests,
# and should reject the rotation by calling reject_rotation()...
piece.reject_rotation()

# If it returned true, and you tried the offset, and it was a legal position,
# then you should accept the rotation...
piece.accept_rotation()

# You must call accept_rotation() or reject_rotation() before calling a
# rotate_<dir> or shift_<dir> after rotate_<dir> has been called. Failing to
# do so will result in undefined behavior.

##### TODO: Add accept and reject rotation
"""


const STARTING_POSITION = Vector2i(4, 19)
const NUM_ORIENTATIONS = 4

# The info of where the bricks of a Tetromino lie relative to its origin point
class PieceShape:
	var m_offsets: Array[Vector2i]
	func _init(zero: Vector2i, one: Vector2i, two: Vector2i, three: Vector2i) -> void:
		m_offsets = [zero, one, two, three]

	func rot_90() -> PieceShape:
		var vecs: Array[Vector2i] = []
		vecs.resize(4)
		for i in range(vecs.size()):
			var x := m_offsets[i].y
			var y := -m_offsets[i].x
			vecs[i] = Vector2i(x, y)

		return PieceShape.new(vecs[0], vecs[1], vecs[2], vecs[3])

	func rot_180() -> PieceShape:
		var vecs: Array[Vector2i] = []
		vecs.resize(4)
		for i in range(vecs.size()):
			vecs[i] = Vector2i(-m_offsets[i].x, -m_offsets[i].y)

		return PieceShape.new(vecs[0], vecs[1], vecs[2], vecs[3])

	func rot_270() -> PieceShape:
		var vecs: Array[Vector2i] = []
		vecs.resize(4)
		for i in range(vecs.size()):
			var x := -m_offsets[i].y
			var y := m_offsets[i].x
			vecs[i] = Vector2i(x, y)

		return PieceShape.new(vecs[0], vecs[1], vecs[2], vecs[3])



# An orientation is the shape a piece takes in a specific rotation, along with
# the offsets that it should test when moving to this orientation to check
# if the rotation is legal.
class PieceOrientation:
	# The brick data for the orientation
	var m_shape: PieceShape
	# The list of tested offsets used for this rotation, in the order they
	# should be checked
	var m_offsets: Array[Vector2i]

	func _init(shape: PieceShape, offsets: Array[Vector2i]):
		m_shape = shape
		m_offsets = offsets


class StaticTetrominoInfo:
	var m_kind: Kind
	var m_rotations: Array[PieceOrientation]

	func _init(spawn: PieceOrientation, right: PieceOrientation, two: PieceOrientation, left: PieceOrientation, kind: Kind) -> void:
		m_rotations = [spawn, right, two, left]
		m_kind = kind

class Piece:
	var m_static_info: StaticTetrominoInfo
	var m_current_rotation: int = 0
	# m_last_rotation is for handling reject_rotation
	var m_last_rotation: int = 0
	var m_test_offsets: Array[Vector2i] = [Vector2i(0, 0)]
	var m_position: Vector2i
	var m_current_offset: int = 0

	func _init(static_info: StaticTetrominoInfo, pos: Vector2i = STARTING_POSITION) -> void:
		m_static_info = static_info
		m_position = pos

	# Update relative piece data to reflect rotating to the left once.
	# The games typically call this left, but I guess it's really
	# counterclockwise.
	# Must call accept_rotation or reject_rotation before performing another
	# rotation or translation after this.
	func rotate_left() -> void:
		self._rotate(-1)

	# Update relative piece data to reflect rotating to the right once.
	# The games typically call this right, but I guess it's really
	# clockwise.
	# Must call accept_rotation or reject_rotation before performing another
	# rotation or translation after this.
	func rotate_right() -> void:
		self._rotate(1)

	func accept_rotation() -> void:
		m_position += m_test_offsets[m_current_offset]
		m_current_offset = 0
		m_test_offsets.resize(1)
		m_test_offsets[0] = Vector2i(0, 0)

	func reject_rotation() -> void:
		m_current_rotation = m_last_rotation
		m_current_offset = 0
		m_test_offsets.resize(1)
		m_test_offsets[0] = Vector2i(0, 0)

	# Changes the position of the piece to be one cell lower. Does not check
	# for passing through the bottom of the board.
	func shift_down() -> void:
		m_position += Vector2i(0, -1)

	# The reason shift_up exists is because I imagine hard drop calc can be done
	# by shifting down until a shift would be illegal, and then shifting back
	# up to the last legal position.
	func shift_up() -> void:
		m_position += Vector2i(0, 1)

	# Changes the position of the piece to be one cell to the left. Does not
	# check for passing through the side of the board.
	func shift_left() -> void:
		m_position += Vector2i(-1, 0)

	# Changes the position of the piece to be one cell to the right. Does not
	# check for passing through the side of the board.
	func shift_right() -> void:
		m_position += Vector2i(1, 0)

	# Returns the absolute positions of the cells occupied by the piece in its
	# current rotation. Positions are interpreted as cell 0, 0 being the bottom
	# left of the board, and increasing to the up and right.
	func get_cells() -> Array[Vector2i]:
		var ret: Array[Vector2i] = []
		ret.resize(NUM_ORIENTATIONS)
		for i in range(NUM_ORIENTATIONS):
			ret[i] = self._get_orientation_for_idx(m_current_rotation).m_shape.m_offsets[i] + m_position + m_test_offsets[m_current_offset]

		return ret

	# Moves the piece to the next test offset in the current rotation. Used for
	# position tests in rotations. Returns true if there was an offset to
	# advance to. Returrs false otherwise.
	func advance_current_offset() -> bool:
		if m_current_offset == m_test_offsets.size() - 1:
			return false

		m_current_offset += 1
		return true

	# Returns the list of offsets to test for the last rotation
	func get_offsets() -> Array[Vector2i]:
		return m_test_offsets

	func get_kind() -> Kind:
		return m_static_info.m_kind

	func _get_orientation_for_idx(idx: int) -> PieceOrientation:
		return m_static_info.m_rotations[idx]

	func _rotate(num: int) -> void:
		m_last_rotation = m_current_rotation
		m_current_rotation = (m_current_rotation + num) % NUM_ORIENTATIONS
		_calc_offsets(self._get_orientation_for_idx(m_last_rotation), _get_orientation_for_idx(m_current_rotation))
		m_current_offset = 0

	# See https://tetris.wiki/Super_Rotation_System "How Guideline SRS Really
	# Works" for an explanation on how test offsets on rotation are calced
	#
	# could optimize and precalc all of these. Being lazy.
	func _calc_offsets(prev: PieceOrientation, next: PieceOrientation) -> void:
		assert(prev.m_offsets.size() == next.m_offsets.size())
		m_test_offsets.resize(prev.m_offsets.size())
		for i in range(prev.m_offsets.size()):
			m_test_offsets[i] = Vector2i(
				prev.m_offsets[i].x - next.m_offsets[i].x,
				prev.m_offsets[i].y - next.m_offsets[i].y,
			)

static var i_shape := PieceShape.new(Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0))

static var TETR_INFO_I: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(
		i_shape,
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, 0)]
	),
	PieceOrientation.new(
		i_shape.rot_90(),
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -2)]
	),
	PieceOrientation.new(
		i_shape.rot_180(),
		[Vector2i(-1, 1), Vector2i(1, 1), Vector2i(-2, 1), Vector2i(1, 0), Vector2i(-2, 0)]
	),
	PieceOrientation.new(
		i_shape.rot_270(),
		[Vector2i(0, 1), Vector2i(0, 1), Vector2i(0, 1), Vector2i(0, -1), Vector2i(0, 2)]
	),
	Kind.I,
)

# Can't do nested type collections, so all four offset sets are in this same
# array, at intervals of 5. Blame the language, not me.
static var JLSTZ_Offsets: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0),
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2),
	Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0),
	Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)
]

static var j_shape := PieceShape.new(Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0))

static var TETR_INFO_J: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(j_shape, JLSTZ_Offsets.slice(0, 5)),
	PieceOrientation.new(j_shape.rot_90(), JLSTZ_Offsets.slice(5, 10)),
	PieceOrientation.new(j_shape.rot_180(), JLSTZ_Offsets.slice(10, 15)),
	PieceOrientation.new(j_shape.rot_270(), JLSTZ_Offsets.slice(15, 20)),
	Kind.J,
)

static var l_shape := PieceShape.new(Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1))

static var TETR_INFO_L: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(l_shape, JLSTZ_Offsets.slice(0, 5)),
	PieceOrientation.new(l_shape.rot_90(), JLSTZ_Offsets.slice(5, 10)),
	PieceOrientation.new(l_shape.rot_180(), JLSTZ_Offsets.slice(10, 15)),
	PieceOrientation.new(l_shape.rot_270(), JLSTZ_Offsets.slice(15, 20)),
	Kind.L,
)

static var s_shape := PieceShape.new(Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1))

static var TETR_INFO_S: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(s_shape, JLSTZ_Offsets.slice(0, 5)),
	PieceOrientation.new(s_shape.rot_90(), JLSTZ_Offsets.slice(5, 10)),
	PieceOrientation.new(s_shape.rot_180(), JLSTZ_Offsets.slice(10, 15)),
	PieceOrientation.new(s_shape.rot_270(), JLSTZ_Offsets.slice(15, 20)),
	Kind.S,
)

static var z_shape := PieceShape.new(Vector2i(-1, 1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0))

static var TETR_INFO_Z: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(z_shape, JLSTZ_Offsets.slice(0, 5)),
	PieceOrientation.new(z_shape.rot_90(), JLSTZ_Offsets.slice(5, 10)),
	PieceOrientation.new(z_shape.rot_180(), JLSTZ_Offsets.slice(10, 15)),
	PieceOrientation.new(z_shape.rot_270(), JLSTZ_Offsets.slice(15, 20)),
	Kind.Z,
)

static var t_shape := PieceShape.new(Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1))

static var TETR_INFO_T: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(t_shape, JLSTZ_Offsets.slice(0, 5)),
	PieceOrientation.new(t_shape.rot_90(), JLSTZ_Offsets.slice(5, 10)),
	PieceOrientation.new(t_shape.rot_180(), JLSTZ_Offsets.slice(10, 15)),
	PieceOrientation.new(t_shape.rot_270(), JLSTZ_Offsets.slice(15, 20)),
	Kind.T,
)

static var o_shape := PieceShape.new(Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1))

static var TETR_INFO_O: StaticTetrominoInfo = StaticTetrominoInfo.new(
	PieceOrientation.new(o_shape, [Vector2i(0, 0)]),
	PieceOrientation.new(o_shape.rot_90(), [Vector2i(0, -1)]),
	PieceOrientation.new(o_shape.rot_180(), [Vector2i(-1, -1)]),
	PieceOrientation.new(o_shape.rot_270(), [Vector2i(-1, 0)]),
	Kind.O,
)

enum Kind {NONE, I, T, O, Z, S, J, L}

static var kind_to_info_table = [
	TETR_INFO_O, # Placeholder for none...
	TETR_INFO_I,
	TETR_INFO_T,
	TETR_INFO_O,
	TETR_INFO_Z,
	TETR_INFO_S,
	TETR_INFO_J,
	TETR_INFO_L,
]

static func kind_to_info(k: Kind) -> StaticTetrominoInfo:
	return kind_to_info_table[k]
