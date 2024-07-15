extends Node

func inputEventFromKey(keycode: Key) -> InputEvent:
	var event = InputEventKey.new()
	event.physical_keycode = keycode
	return event

func _ready() -> void:
	# set up the inputmap. Could also do this in project settings :shrug:
	InputMap.add_action("Shift_Left")
	InputMap.action_add_event("Shift_Left", inputEventFromKey(KEY_A))

	InputMap.add_action("Shift_Right")
	InputMap.action_add_event("Shift_Right", inputEventFromKey(KEY_D))

	InputMap.add_action("Rotate_Left")
	InputMap.action_add_event("Rotate_Left", inputEventFromKey(KEY_Q))

	InputMap.add_action("Rotate_Right")
	InputMap.action_add_event("Rotate_Right", inputEventFromKey(KEY_E))

	InputMap.add_action("Hard_Drop")
	InputMap.action_add_event("Hard_Drop", inputEventFromKey(KEY_W))

	InputMap.add_action("Soft_Drop")
	InputMap.action_add_event("Soft_Drop", inputEventFromKey(KEY_S))

	InputMap.add_action("Hold")
	InputMap.action_add_event("Hold", inputEventFromKey(KEY_SPACE))
