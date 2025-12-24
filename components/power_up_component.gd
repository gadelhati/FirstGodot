# ============================================
# components/power_up_component.gd
# ============================================
class_name PowerUpComponent
extends RefCounted

enum Type {
	HEALTH,
	AMMO,
	WEAPON,
	SPEED,
	DAMAGE_BOOST
}

signal applied(target: Node, type: Type)

var type: Type
var value: float
var duration: float

func _init(p_type: Type, p_value: float, p_duration: float = 0.0):
	type = p_type
	value = p_value
	duration = p_duration

func apply(target: Node) -> bool:
	print("PowerUpComponent.apply() chamado")
	print("Target: ", target.name)
	print("Type: ", Type.keys()[type])
	
	var success = false
	
	match type:
		Type.HEALTH:
			print("Tentando aplicar HEALTH...")
			success = _apply_health(target)
		Type.AMMO:
			print("Tentando aplicar AMMO...")
			success = _apply_ammo(target)
		Type.WEAPON:
			print("Tentando aplicar WEAPON...")
			success = _apply_weapon(target)
		Type.SPEED:
			print("Tentando aplicar SPEED...")
			success = _apply_speed(target)
		Type.DAMAGE_BOOST:
			print("Tentando aplicar DAMAGE_BOOST...")
			success = _apply_damage(target)
	
	if success:
		applied.emit(target, type)
		print("✅ PowerUp aplicado com sucesso!")
	else:
		print("❌ PowerUp falhou ao aplicar")
	
	return success

func _apply_health(target: Node) -> bool:
	print("Verificando método 'heal': ", target.has_method("heal"))
	
	if not target.has_method("heal"):
		return false
	
	print("Curando ", value, " HP")
	target.heal(value)
	return true

func _apply_ammo(target: Node) -> bool:
	print("Verificando método 'add_ammo': ", target.has_method("add_ammo"))
	
	if not target.has_method("add_ammo"):
		return false
	
	print("Adicionando ", int(value), " munição")
	target.add_ammo(int(value))
	return true

func _apply_weapon(target: Node) -> bool:
	print("Verificando método 'add_weapon': ", target.has_method("add_weapon"))
	
	if not target.has_method("add_weapon"):
		return false
	
	# Para weapon, value é o índice/tipo
	target.change_weapon(int(value))
	return true

func _apply_speed(target: Node) -> bool:
	print("Verificando método 'apply_speed_boost': ", target.has_method("apply_speed_boost"))
	
	if not target.has_method("apply_speed_boost"):
		return false
	
	print("Aplicando speed boost de ", value, " por ", duration, "s")
	target.apply_speed_boost(value, duration)
	return true

func _apply_damage(target: Node) -> bool:
	print("Verificando método 'apply_damage_boost': ", target.has_method("apply_damage_boost"))
	
	if not target.has_method("apply_damage_boost"):
		return false
	
	print("Aplicando damage boost de ", value, " por ", duration, "s")
	target.apply_damage_boost(value, duration)
	return true
