# ============================================
# resources/weapon_data.gd
# ============================================
class_name WeaponData
extends Resource

@export var name: String = "Pistol"
@export var damage: float = 25.0
@export var speed: float = 500.0
@export var max_range: float = 1000.0
@export var rate: float = 0.2
@export var max_ammo: int = 30
@export var cost: int = 1
@export var scene: PackedScene

static func pistol() -> WeaponData:
	return _create("Pistol", 25.0, 500.0, 1000.0, 0.2, 30)

static func shotgun() -> WeaponData:
	return _create("Shotgun", 75.0, 400.0, 500.0, 0.8, 8)

static func machinegun() -> WeaponData:
	return _create("Machine Gun", 15.0, 600.0, 1200.0, 0.05, 100)

static func sniper() -> WeaponData:
	return _create("Sniper", 100.0, 800.0, 2000.0, 1.5, 10)

static func _create(p_name: String, dmg: float, spd: float, rng: float, rt: float, ammo: int) -> WeaponData:
	var data = WeaponData.new()
	data.name = p_name
	data.damage = dmg
	data.speed = spd
	data.max_range = rng
	data.rate = rt
	data.max_ammo = ammo
	data.cost = 1
	return data
