# ============================================
# resources/weapon_data.gd
# ============================================
class_name WeaponData
extends Resource

@export var weapon_name: String = "Pistol"
@export var damage: float = 25.0
@export var bullet_speed: float = 500.0
@export var bullet_range: float = 1000.0
@export var fire_rate: float = 0.2
@export var max_ammo: int = 30
@export var ammo_per_shot: int = 1
@export var bullet_scene: PackedScene

static func create_pistol() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "Pistol"
	data.damage = 25.0
	data.bullet_speed = 500.0
	data.bullet_range = 1000.0
	data.fire_rate = 0.2
	data.max_ammo = 30
	data.ammo_per_shot = 1
	return data

static func create_shotgun() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "Shotgun"
	data.damage = 75.0
	data.bullet_speed = 400.0
	data.bullet_range = 500.0
	data.fire_rate = 0.8
	data.max_ammo = 8
	data.ammo_per_shot = 1
	return data

static func create_machinegun() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "Machine Gun"
	data.damage = 15.0
	data.bullet_speed = 600.0
	data.bullet_range = 1200.0
	data.fire_rate = 0.05
	data.max_ammo = 100
	data.ammo_per_shot = 1
	return data

static func create_sniper() -> WeaponData:
	var data = WeaponData.new()
	data.weapon_name = "Sniper"
	data.damage = 100.0
	data.bullet_speed = 800.0
	data.bullet_range = 2000.0
	data.fire_rate = 1.5
	data.max_ammo = 10
	data.ammo_per_shot = 1
	return data
