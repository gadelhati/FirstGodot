# ============================================
# components/damage_dealer_component.gd
# ============================================
class_name DamageDealerComponent
extends RefCounted

var damage: float
var pierce: bool
var hits: Array[Node] = []

func _init(dmg: float, can_pierce: bool = false):
	damage = dmg
	pierce = can_pierce

func try_damage(target: Node) -> bool:
	if not _can_hit(target):
		return false
	
	target.take_damage(damage)
	hits.append(target)
	return true

func _can_hit(target: Node) -> bool:
	return target.has_method("take_damage") and \
		   (pierce or target not in hits)

func reset():
	hits.clear()
