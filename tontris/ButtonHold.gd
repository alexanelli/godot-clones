extends Resource

class_name ButtonHold

enum HoldType {
	NONE,
	SHIFT_LEFT,
	SHIFT_RIGHT,
	SOFT_DROP
}

var m_hold_type: HoldType = HoldType.NONE
var m_last_repeat_tick: int = 0
var m_initial_wait_time_usec: int = 0
var m_repeat_time_usec: int = 0

func _init(initial_wait_time_msec: int, repeat_time_msec: int):
	m_initial_wait_time_usec = initial_wait_time_msec * 1000
	m_repeat_time_usec = repeat_time_msec * 1000

func currently_holding() -> HoldType:
	return m_hold_type

func begin_hold(t: HoldType) -> void:
	m_hold_type = t
	# Seed the last repeat time as the time we want the repeat to occur at
	# minus the interval that a repeat happens at.
	m_last_repeat_tick = Time.get_ticks_usec() + m_initial_wait_time_usec - m_repeat_time_usec

"""
Releases the current hold if the given hold is of the current hold type
"""
func release(t: HoldType) -> void:
	if m_hold_type == t:
		m_hold_type = HoldType.NONE

"""
Returns the number of repeats that should occur since the last time this function
was called
"""
func get_repeats() -> int:
	var current_tick := Time.get_ticks_usec()
	var repeats := (current_tick - m_last_repeat_tick) / m_repeat_time_usec
	m_last_repeat_tick += m_repeat_time_usec * repeats
	return repeats
