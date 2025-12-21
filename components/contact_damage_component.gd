# ============================================
# COMPONENTES COMPARTILHADOS (components/contact_damage_component.gd)
# ============================================
class_name ContactDamageComponent
extends RefCounted

signal damage_dealt(target: Node, damage: float)
signal cooldown_started(target: Node)
signal cooldown_finished(target: Node)

var owner_node: Node
var damage: float
var cooldown_duration: float
var targets_on_cooldown: Dictionary = {}

func _init(p_owner: Node, p_damage: float, p_cooldown: float = 1.0):
	owner_node = p_owner
	damage = p_damage
	cooldown_duration = p_cooldown

func try_deal_contact_damage(target: Node) -> bool:
	if not target.has_method("take_damage"):
		return false
	
	if target == owner_node:
		return false
	
	if is_on_cooldown(target):
		return false
	
	target.take_damage(damage)
	damage_dealt.emit(target, damage)
	_start_cooldown(target)
	return true

func is_on_cooldown(target: Node) -> bool:
	return target in targets_on_cooldown

func _start_cooldown(target: Node):
	cooldown_started.emit(target)
	var timer = owner_node.get_tree().create_timer(cooldown_duration)
	targets_on_cooldown[target] = timer
	await timer.timeout
	targets_on_cooldown.erase(target)
	cooldown_finished.emit(target)

func set_damage(new_damage: float):
	damage = new_damage

func set_cooldown(new_cooldown: float):
	cooldown_duration = new_cooldown

func clear_cooldowns():
	targets_on_cooldown.clear()
