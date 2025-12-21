# ============================================
# COMPONENTES COMPARTILHADOS (components/health_component.gd)
# ============================================
class_name HealthComponent
extends RefCounted

signal health_changed(current: float, maximum: float)
signal damage_taken(damage: float, current: float)
signal healed(amount: float, current: float)
signal death()

var max_hp: float
var current_hp: float

func _init(p_max_hp: float):
	max_hp = p_max_hp
	current_hp = max_hp

func take_damage(damage: float):
	if not is_alive():
		return
	
	var actual_damage = min(damage, current_hp)
	current_hp -= actual_damage
	current_hp = clamp(current_hp, 0, max_hp)
	
	damage_taken.emit(actual_damage, current_hp)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		death.emit()

func heal(amount: float):
	if not is_alive():
		return
	
	var old_hp = current_hp
	current_hp = min(current_hp + amount, max_hp)
	var actual_heal = current_hp - old_hp
	
	if actual_heal > 0:
		healed.emit(actual_heal, current_hp)
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
