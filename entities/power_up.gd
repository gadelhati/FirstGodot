# ============================================
# entities/power_up.gd
# ============================================
class_name PowerUp
extends Area2D

signal collected(collector: Node)

var power_up: PowerUpComponent
var collected_by: Array[Node] = []

@export_group("Power-Up Config")
@export var type: PowerUpComponent.Type = PowerUpComponent.Type.HEALTH
@export var value: float = 50.0
@export var duration: float = 0.0
@export var respawn_time: float = 0.0
@export var one_time_only: bool = true

@export_group("Visual")
@export var sprite: Sprite2D
@export var particles: GPUParticles2D

var active: bool = true

func _ready():
	power_up = PowerUpComponent.new(type, value, duration)
	body_entered.connect(_on_body_entered)
	
	# Configura collision
	collision_layer = 4
	collision_mask = 1 | 3  # Hero (1) e Enemy (3)
	
	_setup_default_visual()

func _setup_default_visual():
	if not sprite:
		return
	
	match type:
		PowerUpComponent.Type.HEALTH:
			sprite.modulate = Color.GREEN
		PowerUpComponent.Type.AMMO:
			sprite.modulate = Color.YELLOW
		PowerUpComponent.Type.WEAPON:
			sprite.modulate = Color.CYAN
		PowerUpComponent.Type.SPEED:
			sprite.modulate = Color.BLUE
		PowerUpComponent.Type.DAMAGE_BOOST:
			sprite.modulate = Color.RED

func _on_body_entered(body: Node2D):
	print("=== POWERUP DEBUG ===")
	print("Body entered: ", body.name)
	print("Active: ", active)
	print("Type: ", PowerUpComponent.Type.keys()[type])
	print("Value: ", value)
	
	if not active:
		print("❌ PowerUp não está ativo")
		return
	
	# Verifica se já coletou
	if one_time_only and body in collected_by:
		print("❌ Já foi coletado por este corpo")
		return
	
	# Tenta aplicar o power-up
	var success = power_up.apply(body)
	print("Aplicação: ", "✅ Sucesso" if success else "❌ Falhou")
	
	if success:
		collected_by.append(body)
		collected.emit(body)
		_on_collected()

func _on_collected():
	active = false
	visible = false
	
	if particles:
		particles.emitting = true
	
	if respawn_time > 0:
		await get_tree().create_timer(respawn_time).timeout
		_respawn()
	else:
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _respawn():
	active = true
	visible = true
	
	if not one_time_only:
		collected_by.clear()
	
	print("PowerUp respawned!")
