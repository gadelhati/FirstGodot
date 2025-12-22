# ============================================
# UI/fire_button.gd
# ============================================
class_name FireButton
extends Control

signal button_pressed()
signal button_released()

# Configurações
@export var button_radius: float = 60.0
@export var auto_fire: bool = true  # Disparo automático ao segurar

# Cores
@export var normal_color: Color = Color(1, 0.2, 0.2, 0.5)
@export var pressed_color: Color = Color(1, 0.4, 0.4, 0.8)

# Estado
var is_pressed: bool = false
var touch_index: int = -1

func _ready():
	custom_minimum_size = Vector2(button_radius * 2, button_radius * 2)
	# Esconde em desktop
	visible = true #OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios") or OS.get_name() == "Android" or OS.get_name() == "iOS" or OS.has_feature("web_android") or OS.has_feature("web_ios")

func _draw():
	var color = pressed_color if is_pressed else normal_color
	draw_circle(Vector2(button_radius, button_radius), button_radius, color)
	
	# Desenha ícone de mira
	var center = Vector2(button_radius, button_radius)
	var cross_size = button_radius * 0.4
	var thickness = 3.0
	
	# Linhas da mira
	draw_line(center + Vector2(-cross_size, 0), center + Vector2(cross_size, 0), Color.WHITE, thickness)
	draw_line(center + Vector2(0, -cross_size), center + Vector2(0, cross_size), Color.WHITE, thickness)
	
	# Círculo central
	draw_circle(center, cross_size * 0.3, Color.WHITE)
	draw_circle(center, cross_size * 0.2, color)

func _gui_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_press(event.index)
		else:
			_end_press(event.index)
	
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			# Mantém pressionado se ainda dentro da área
			var local_pos = event.position
			var distance = local_pos.distance_to(Vector2(button_radius, button_radius))
			
			if distance > button_radius and is_pressed:
				_end_press(event.index)

func _start_press(index: int):
	if touch_index == -1:
		touch_index = index
		is_pressed = true
		button_pressed.emit()
		queue_redraw()

func _end_press(index: int):
	if index == touch_index:
		touch_index = -1
		is_pressed = false
		button_released.emit()
		queue_redraw()

func get_is_pressed() -> bool:
	return is_pressed

func reset():
	touch_index = -1
	is_pressed = false
	queue_redraw()
