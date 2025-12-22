# ============================================
# components/ammo_component.gd
# ============================================
class_name AmmoComponent
extends RefCounted

signal ammo_changed(current: int, maximum: int)
signal ammo_depleted()
signal ammo_reloaded()

var max_ammo: int
var current_ammo: int
var infinite: bool

func _init(p_max_ammo: int, p_infinite: bool = false):
	max_ammo = p_max_ammo
	current_ammo = max_ammo
	infinite = p_infinite

func can_shoot() -> bool:
	return infinite or current_ammo > 0

func consume(amount: int = 1) -> bool:
	if infinite:
		return true
	
	if current_ammo < amount:
		ammo_depleted.emit()
		return false
	
	current_ammo -= amount
	ammo_changed.emit(current_ammo, max_ammo)
	
	if current_ammo == 0:
		ammo_depleted.emit()
	
	return true

func reload(amount: int = -1):
	if infinite:
		return
	
	# -1 = reload full
	if amount < 0:
		current_ammo = max_ammo
	else:
		current_ammo = min(current_ammo + amount, max_ammo)
	
	ammo_changed.emit(current_ammo, max_ammo)
	ammo_reloaded.emit()

func get_current() -> int:
	return current_ammo if not infinite else 999

func get_max() -> int:
	return max_ammo

func get_percentage() -> float:
	if infinite:
		return 100.0
	return (float(current_ammo) / float(max_ammo)) * 100.0 if max_ammo > 0 else 0.0

func is_empty() -> bool:
	return not infinite and current_ammo <= 0

func is_full() -> bool:
	return infinite or current_ammo >= max_ammo

func set_infinite(value: bool):
	infinite = value
