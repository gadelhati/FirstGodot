# ============================================
# components/inventory_component.gd
# ============================================
class_name InventoryComponent
extends RefCounted

signal weapon_changed(old_index: int, new_index: int)
signal weapon_added(weapon: WeaponData, index: int)

var weapons: Array[WeaponData] = []
var current_index: int = 0
var max_weapons: int = 4

func _init(p_max_weapons: int = 4):
	max_weapons = p_max_weapons

func add_weapon(weapon: WeaponData) -> int:
	if weapons.size() >= max_weapons:
		# Substitui arma atual
		weapons[current_index] = weapon
		weapon_added.emit(weapon, current_index)
		return current_index
	else:
		weapons.append(weapon)
		var index = weapons.size() - 1
		weapon_added.emit(weapon, index)
		return index

func get_current_weapon() -> WeaponData:
	if weapons.is_empty():
		return null
	return weapons[current_index]

func change_weapon(index: int) -> bool:
	if index < 0 or index >= weapons.size():
		return false
	
	var old = current_index
	current_index = index
	weapon_changed.emit(old, current_index)
	return true

func next_weapon():
	if weapons.size() <= 1:
		return
	
	var old = current_index
	current_index = (current_index + 1) % weapons.size()
	weapon_changed.emit(old, current_index)

func previous_weapon():
	if weapons.size() <= 1:
		return
	
	var old = current_index
	current_index = (current_index - 1 + weapons.size()) % weapons.size()
	weapon_changed.emit(old, current_index)

func has_weapon(weapon_name: String) -> bool:
	for weapon in weapons:
		if weapon.weapon_name == weapon_name:
			return true
	return false

func get_weapon_count() -> int:
	return weapons.size()
