# ============================================
# entities/weapon_pickup.gd
# ============================================
extends PowerUp

@export var weapon_type: int = 0  # 0=Pistol, 1=Shotgun, 2=MachineGun, 3=Sniper

func _ready():
	super._ready()
	type = PowerUpComponent.Type.WEAPON
	value = weapon_type

func _on_body_entered(body: Node2D):
	if not active:
		return
	
	if body.has_method("add_weapon"):
		var weapon_data: WeaponData
		
		match weapon_type:
			0: weapon_data = WeaponData.create_pistol()
			1: weapon_data = WeaponData.create_shotgun()
			2: weapon_data = WeaponData.create_machinegun()
			3: weapon_data = WeaponData.create_sniper()
		
		if weapon_data:
			weapon_data.bullet_scene = body.bullet_scene
			body.add_weapon(weapon_data)
			collected.emit(body)
			_on_collected()
	
