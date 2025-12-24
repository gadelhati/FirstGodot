# ============================================
# components/power_up_component.gd (REFATORADO)
# ============================================
class_name PowerUpComponent
extends RefCounted

enum Type { HEALTH, AMMO, WEAPON, SPEED, DAMAGE_BOOST }

var type: Type
var value: float
var duration: float

func _init(p_type: Type, p_value: float, p_duration: float = 0.0):
	type = p_type
	value = p_value
	duration = p_duration

func apply(target: Node) -> bool:
	const METHODS = {
		Type.HEALTH: "heal",
		Type.AMMO: "add_ammo",
		Type.WEAPON: "change_weapon",
		Type.SPEED: "apply_speed_boost",
		Type.DAMAGE_BOOST: "apply_damage_boost"
	}
	
	var method = METHODS.get(type)
	if not method or not target.has_method(method):
		return false
	
	match type:
		Type.HEALTH, Type.AMMO:
			target.call(method, value if type == Type.HEALTH else int(value))
		Type.WEAPON:
			target.call(method, int(value))
		Type.SPEED, Type.DAMAGE_BOOST:
			target.call(method, value, duration)
	
	return true
