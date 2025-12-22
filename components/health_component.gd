# ============================================
# COMPONENTES COMPARTILHADOS (components/health_component.gd)
# ============================================
class_name HealthComponent
extends RefCounted

signal health_changed(current: float, maximum: float)
signal death()

var max_hp: float
var current_hp: float

func _init(p_max_hp: float):
	max_hp = p_max_hp
	current_hp = max_hp

func take_damage(amount: float):
	if not is_alive():
		return
	
	current_hp = clamp(current_hp - amount, 0, max_hp)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		death.emit()

func heal(amount: float):
	if not is_alive():
		return
	
	current_hp = clamp(current_hp + amount, 0, max_hp)
	health_changed.emit(current_hp, max_hp)

func get_current_hp() -> float:
	return current_hp

func get_max_hp() -> float:
	return max_hp

func get_hp_percentage() -> float:
	return (current_hp / max_hp) * 100.0 if max_hp > 0 else 0.0

func is_alive() -> bool:
	return current_hp > 0

func reset():
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)
