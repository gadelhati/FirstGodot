# ============================================
# entities/weapon_pickup.gd
# ============================================
extends PowerUp

@export var weapon_type: int = 0

func _ready():
	super._ready()
	type = PowerUpComponent.Type.WEAPON
	value = weapon_type

func _on_body_entered(body: Node2D):
	if not active or not body.has_method("add_weapon"):
		return
	
	var weapon_data: WeaponData
	
	match weapon_type:
		0: weapon_data = WeaponData.pistol()
		1: weapon_data = WeaponData.shotgun()
		2: weapon_data = WeaponData.machinegun()
		3: weapon_data = WeaponData.sniper()
		_: return
	
	weapon_data.scene = body.bullet_scene
	body.add_weapon(weapon_data)
	collected.emit(body)
	_collect()
