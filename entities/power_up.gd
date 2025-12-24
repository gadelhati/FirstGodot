# ============================================
# entities/power_up.gd
# ============================================
class_name PowerUp
extends Area2D

signal collected(collector: Node)

var component: PowerUpComponent
var collected_by: Array[Node] = []
var active: bool = true

@export_group("Config")
@export var type: PowerUpComponent.Type = PowerUpComponent.Type.HEALTH
@export var value: float = 50.0
@export var duration: float = 0.0
@export var respawn_time: float = 0.0
@export var one_time: bool = true

@export_group("Visual")
@export var sprite: Sprite2D
@export var particles: GPUParticles2D

func _ready():
	component = PowerUpComponent.new(type, value, duration)
	body_entered.connect(_on_body_entered)
	_setup_collision()
	_setup_visual()

func _setup_collision():
	collision_layer = 4
	collision_mask = 1 | 3

func _setup_visual():
	if not sprite:
		return
	
	const COLORS = {
		PowerUpComponent.Type.HEALTH: Color.GREEN,
		PowerUpComponent.Type.AMMO: Color.YELLOW,
		PowerUpComponent.Type.WEAPON: Color.CYAN,
		PowerUpComponent.Type.SPEED: Color.BLUE,
		PowerUpComponent.Type.DAMAGE_BOOST: Color.RED
	}
	sprite.modulate = COLORS.get(type, Color.WHITE)

func _on_body_entered(body: Node2D):
	if not active or (one_time and body in collected_by):
		return
	
	if component.apply(body):
		collected_by.append(body)
		collected.emit(body)
		_collect()

func _collect():
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
	if not one_time:
		collected_by.clear()
