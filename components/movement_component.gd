# ============================================
# COMPONENTES COMPARTILHADOS (components/movement_component.gd)
# ============================================
class_name MovementComponent
extends RefCounted

var speed: float
var input_enabled: bool = true

func _init(p_speed: float):
	speed = p_speed

func get_input_vector() -> Vector2:
	if not input_enabled:
		return Vector2.ZERO
	
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	
	return input_vector.normalized()

func calculate_velocity(input_vector: Vector2) -> Vector2:
	return input_vector * speed

func set_speed(new_speed: float):
	speed = max(0, new_speed)

func disable_input():
	input_enabled = false

func enable_input():
	input_enabled = true
