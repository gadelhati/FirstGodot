# ============================================
# components/contact_damage_component.gd
# ============================================
class_name ContactDamageComponent
extends RefCounted

var owner: Node
var damage: float
var cooldown: float
var target_groups: Array[String] = []
var _cooldowns: Dictionary = {}

func _init(p_owner: Node, p_damage: float, p_cooldown: float = 1.0):
	owner = p_owner
	damage = p_damage
	cooldown = p_cooldown

func set_target_groups(groups: Array[String]):
	target_groups = groups

func try_damage(target: Node) -> bool:
	if not _can_damage(target):
		return false
	
	if target.has_method("take_damage"):
		target.take_damage(damage)
		_start_cooldown(target)
		return true
	
	return false

func _can_damage(target: Node) -> bool:
	# Verifica se target é válido
	if not is_instance_valid(target) or target == owner:
		return false
	
	# Se não tem método take_damage, não pode causar dano
	if not target.has_method("take_damage"):
		return false
	
	# Se está em cooldown, não causa dano
	if _cooldowns.get(target, false):
		return false
	
	# Se tem grupos específicos configurados, verifica se o alvo pertence a algum
	if not target_groups.is_empty():
		var target_is_valid = false
		for group in target_groups:
			if target.is_in_group(group):
				target_is_valid = true
				break
		
		if not target_is_valid:
			return false
	
	return true

func _start_cooldown(target: Node):
	_cooldowns[target] = true
	await owner.get_tree().create_timer(cooldown).timeout
	_cooldowns.erase(target)
