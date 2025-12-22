# ============================================
# UI (UI/health_bar.gd)
# ============================================
class_name HealthBar
extends ProgressBar

@export var colored: bool = true

var health: HealthComponent

func initialize(health_component: HealthComponent):
	health = health_component
	health.health_changed.connect(_on_health_changed)
	_update(health.get_current_hp(), health.get_max_hp())

func _on_health_changed(current: float, maximum: float):
	_update(current, maximum)

func _update(current: float, maximum: float):
	max_value = maximum
	value = current
	
	if colored:
		_update_color()

func _update_color():
	var percent = health.get_hp_percentage()
	
	if percent > 60:
		modulate = Color.GREEN
	elif percent > 30:
		modulate = Color.YELLOW
	else:
		modulate = Color.RED
