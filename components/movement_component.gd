# ============================================
# components/movement_component.gd (ATUALIZADO)
# ============================================
class_name MovementComponent
extends RefCounted

var speed: float
var input_manager: InputManagerComponent

func _init(p_speed: float):
	speed = p_speed
	input_manager = InputManagerComponent.new()

func set_virtual_controls(joystick, button):
	input_manager.set_virtual_controls(joystick, button)

func get_input_vector() -> Vector2:
	return input_manager.get_movement_input()

func calculate_velocity(input_vector: Vector2) -> Vector2:
	return input_vector * speed

func set_speed(new_speed: float):
	speed = max(0, new_speed)

func disable_input():
	input_manager.set_input_enabled(false)

func enable_input():
	input_manager.set_input_enabled(true)

func get_input_manager() -> InputManagerComponent:
	return input_manager
