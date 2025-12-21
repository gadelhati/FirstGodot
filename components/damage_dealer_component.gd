# ============================================
# COMPONENTES COMPARTILHADOS (components/damage_dealer_component.gd)
# ============================================
class_name DamageDealerComponent
extends RefCounted

signal damage_dealt(target: Node, damage: float)

var damage: float
var can_hit_multiple: bool
var targets_hit: Array[Node] = []

func _init(p_damage: float, p_can_hit_multiple: bool = false):
	damage = p_damage
	can_hit_multiple = p_can_hit_multiple

func try_deal_damage(target: Node) -> bool:
	# Verifica se já atingiu esse alvo
	if not can_hit_multiple and target in targets_hit:
		return false
	
	# Verifica se o alvo pode receber dano
	if not target.has_method("take_damage"):
		return false
	
	# Aplica dano
	target.take_damage(damage)
	targets_hit.append(target)
	damage_dealt.emit(target, damage)
	return true

func has_hit_target(target: Node) -> bool:
	return target in targets_hit

func reset_hits():
	targets_hit.clear()
