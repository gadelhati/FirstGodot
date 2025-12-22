# ============================================
# COMPONENTES COMPARTILHADOS (components/contact_damage_component.gd)
# ============================================
class_name ContactDamageComponent
extends RefCounted

var owner: Node
var damage: float
var cooldown: float
var _cooldowns: Dictionary = {}  # {Node: bool}

func _init(p_owner: Node, p_damage: float, p_cooldown: float = 1.0):
	owner = p_owner
	damage = p_damage
	cooldown = p_cooldown

func try_damage(target: Node) -> bool:
	if not _can_damage(target):
		return false
	
	target.take_damage(damage)
	_start_cooldown(target)
	return true

func _can_damage(target: Node) -> bool:
	return target != owner and \
		   target.has_method("take_damage") and \
		   not _cooldowns.get(target, false)

func _start_cooldown(target: Node):
	_cooldowns[target] = true
	await owner.get_tree().create_timer(cooldown).timeout
	_cooldowns.erase(target)
