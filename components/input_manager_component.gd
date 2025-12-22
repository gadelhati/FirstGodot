# ============================================
# components/input_manager_component.gd
# ============================================
class_name InputManagerComponent
extends RefCounted

enum Mode { KEYBOARD, TOUCH, AUTO }

var mode: Mode = Mode.AUTO
var enabled: bool = true
var joystick = null
var button = null

func set_controls(p_joystick, p_button):
	joystick = p_joystick
	button = p_button

func get_movement() -> Vector2:
	if not enabled:
		return Vector2.ZERO
	
	return _get_keyboard() if _is_desktop() else _get_touch()

func is_shooting() -> bool:
	if not enabled:
		return false
	
	if _is_desktop():
		return Input.is_action_pressed("shoot") or \
			   Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	else:
		return button != null and button.get_is_pressed()

func get_aim_target(from: Vector2) -> Vector2:
	if _is_desktop():
		return _get_mouse_pos()
	
	# Touch: atira na direção do movimento
	if joystick:
		var dir = joystick.get_direction()
		if dir.length() > 0:
			return from + (dir * 1000.0)
	
	return from + Vector2.RIGHT * 100

func _is_desktop() -> bool:
	if mode == Mode.KEYBOARD:
		return true
	if mode == Mode.TOUCH:
		return false
	
	# AUTO: detecta plataforma
	return not (OS.has_feature("mobile") or \
				OS.has_feature("android") or \
				OS.get_name() == "Android")

func _get_keyboard() -> Vector2:
	var dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		dir.y -= 1
	
	return dir.normalized()

func _get_touch() -> Vector2:
	return joystick.get_direction() if joystick else Vector2.ZERO

func _get_mouse_pos() -> Vector2:
	var tree = Engine.get_main_loop()
	return tree.root.get_mouse_position() if tree is SceneTree else Vector2.ZERO
