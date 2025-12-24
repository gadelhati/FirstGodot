# ============================================
# UI/ammo_bar.gd
# ============================================
class_name AmmoBar
extends ProgressBar

@export var colored: bool = true
@export var show_numbers: bool = true

var ammo: AmmoComponent
var label: Label

func _ready():
	if show_numbers:
		_create_label()

func _create_label():
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	add_child(label)
	
	# Centraliza o label
	label.anchors_preset = Control.PRESET_FULL_RECT
	label.offset_left = 0
	label.offset_top = 0
	label.offset_right = 0
	label.offset_bottom = 0

func initialize(ammo_component: AmmoComponent):
	# Desconecta signal anterior se existir
	if ammo and ammo.ammo_changed.is_connected(_on_ammo_changed):
		ammo.ammo_changed.disconnect(_on_ammo_changed)
	
	ammo = ammo_component
	
	# Conecta novo signal
	if not ammo.ammo_changed.is_connected(_on_ammo_changed):
		ammo.ammo_changed.connect(_on_ammo_changed)
	
	_update(ammo.get_current(), ammo.get_max())

func _on_ammo_changed(current: int, maximum: int):
	_update(current, maximum)

func _update(current: int, maximum: int):
	max_value = maximum
	value = current
	
	if show_numbers and label:
		if ammo and ammo.infinite:
			label.text = "∞"
		else:
			label.text = "%d / %d" % [current, maximum]
	
	if colored:
		_update_color()

func _update_color():
	if not ammo:
		return
	
	var percent = ammo.get_percentage()
	
	if percent > 60:
		modulate = Color.CYAN
	elif percent > 30:
		modulate = Color.YELLOW
	elif percent > 0:
		modulate = Color.ORANGE
	else:
		modulate = Color.RED
