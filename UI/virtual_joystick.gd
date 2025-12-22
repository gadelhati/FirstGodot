# ============================================
# UI/virtual_joystick.gd
# ============================================
# ============================================
# UI/virtual_joystick.gd (CORRIGIDO)
# ============================================
class_name VirtualJoystick
extends Control

signal direction_changed(direction: Vector2)

# Configurações
@export var joystick_radius: float = 80.0
@export var stick_radius: float = 30.0
@export var dead_zone: float = 0.2
@export var return_to_center: bool = true

# Cores
@export var base_color: Color = Color(1, 1, 1, 0.3)
@export var stick_color: Color = Color(1, 1, 1, 0.8)

# Estado
var touch_index: int = -1
var current_direction: Vector2 = Vector2.ZERO
var stick_offset: Vector2 = Vector2.ZERO

func _ready():
	# Define tamanho do Control
	custom_minimum_size = Vector2(joystick_radius * 2, joystick_radius * 2)
	size = custom_minimum_size
	
	# Detecta mobile
	visible = OS.has_feature("mobile") or \
			  OS.has_feature("android") or \
			  OS.get_name() == "Android"

func _draw():
	var center = size / 2  # Centro do Control
	
	# Desenha base
	draw_circle(center, joystick_radius, base_color)
	
	# Desenha stick (centro + offset)
	draw_circle(center + stick_offset, stick_radius, stick_color)

func _gui_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_touch(event.index, event.position)
		else:
			_end_touch(event.index)
	
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_touch(event.position)

func _start_touch(index: int, pos: Vector2):
	if touch_index == -1:
		touch_index = index
		_update_touch(pos)

func _update_touch(pos: Vector2):
	var center = size / 2
	
	# Calcula offset do centro
	var offset = pos - center
	var distance = offset.length()
	
	# Limita ao raio do joystick
	if distance > joystick_radius:
		offset = offset.normalized() * joystick_radius
	
	# Atualiza posição do stick
	stick_offset = offset
	
	# Calcula direção normalizada
	var direction = offset / joystick_radius
	
	# Aplica dead zone
	if direction.length() < dead_zone:
		direction = Vector2.ZERO
	else:
		direction = direction.normalized() * ((direction.length() - dead_zone) / (1.0 - dead_zone))
	
	# Emite signal se mudou
	if direction != current_direction:
		current_direction = direction
		direction_changed.emit(direction)
	
	queue_redraw()

func _end_touch(index: int):
	if index == touch_index:
		touch_index = -1
		
		if return_to_center:
			stick_offset = Vector2.ZERO
			current_direction = Vector2.ZERO
			direction_changed.emit(Vector2.ZERO)
			queue_redraw()

func get_direction() -> Vector2:
	return current_direction

func reset():
	touch_index = -1
	stick_offset = Vector2.ZERO
	current_direction = Vector2.ZERO
	queue_redraw()
