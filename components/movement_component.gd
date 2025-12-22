# ============================================
# components/movement_component.gd
# ============================================
class_name MovementComponent
extends RefCounted

var speed: float
var input: InputManagerComponent

func _init(p_speed: float):
	speed = p_speed
	input = InputManagerComponent.new()

func set_virtual_controls(joystick, button):
	input.set_controls(joystick, button)

func get_input_vector() -> Vector2:
	return input.get_movement()

func calculate_velocity(direction: Vector2) -> Vector2:
	return direction * speed

func set_speed(new_speed: float):
	speed = max(0, new_speed)

func enable():
	input.enabled = true

func disable():
	input.enabled = false

func get_input_manager() -> InputManagerComponent:
	return input
