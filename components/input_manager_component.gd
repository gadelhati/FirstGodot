# ============================================
# components/input_manager_component.gd
# ============================================
class_name InputManagerComponent
extends RefCounted

signal input_enabled_changed(enabled: bool)

enum InputMode {
	KEYBOARD_MOUSE,
	TOUCH,
	AUTO
}

var input_mode: InputMode = InputMode.AUTO
var input_enabled: bool = true

# Referências para controles virtuais (sem type hint para evitar dependência circular)
var virtual_joystick = null  # VirtualJoystick
var fire_button = null  # FireButton

func _init(mode: InputMode = InputMode.AUTO):
	input_mode = mode

func set_virtual_controls(joystick, button):
	virtual_joystick = joystick
	fire_button = button

func get_movement_input() -> Vector2:
	if not input_enabled:
		return Vector2.ZERO
	
	var input_vector = Vector2.ZERO
	var current_mode = _get_current_mode()
	
	match current_mode:
		InputMode.KEYBOARD_MOUSE:
			input_vector = _get_keyboard_input()
		InputMode.TOUCH:
			input_vector = _get_touch_input()
	
	return input_vector.normalized()

func get_shoot_input() -> bool:
	if not input_enabled:
		return false
	
	var current_mode = _get_current_mode()
	
	match current_mode:
		InputMode.KEYBOARD_MOUSE:
			return Input.is_action_pressed("shoot") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		InputMode.TOUCH:
			return fire_button != null and fire_button.get_is_pressed()
	
	return false

func get_aim_position(from_position: Vector2) -> Vector2:
	var current_mode = _get_current_mode()
	
	match current_mode:
		InputMode.KEYBOARD_MOUSE:
			return _get_mouse_position()
		InputMode.TOUCH:
			if virtual_joystick != null:
				var direction = virtual_joystick.get_direction()
				if direction.length() > 0:
					return from_position + (direction * 1000.0)
			return from_position + Vector2.RIGHT * 100
	
	return from_position + Vector2.RIGHT * 100

func _get_mouse_position() -> Vector2:
	var tree = Engine.get_main_loop()
	if tree and tree is SceneTree:
		return tree.root.get_mouse_position()
	return Vector2.ZERO

func _get_current_mode() -> InputMode:
	if input_mode != InputMode.AUTO:
		return input_mode
	
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return InputMode.TOUCH
	else:
		return InputMode.KEYBOARD_MOUSE

func _get_keyboard_input() -> Vector2:
	var input = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input.y -= 1
	
	return input

func _get_touch_input() -> Vector2:
	if virtual_joystick != null:
		return virtual_joystick.get_direction()
	return Vector2.ZERO

func set_input_enabled(enabled: bool):
	input_enabled = enabled
	input_enabled_changed.emit(enabled)

func is_input_enabled() -> bool:
	return input_enabled

func set_input_mode(mode: InputMode):
	input_mode = mode
