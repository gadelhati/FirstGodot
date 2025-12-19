extends CharacterBody2D

# HP do inimigo
@export var max_hp: float = 100.0
@export var current_hp: float = 100.0

# Referência à barra de HP
@onready var health_bar = $HealthBar

func _ready():
	current_hp = max_hp
	update_health_bar()

func take_damage(damage: float):
	current_hp -= damage
	current_hp = clamp(current_hp, 0, max_hp)
	update_health_bar()
	
	# Feedback visual (opcional)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# Verifica se morreu
	if current_hp <= 0:
		die()

func update_health_bar():
	if health_bar:
		health_bar.value = (current_hp / max_hp) * 100

func die():
	# Animação de morte ou efeitos
	queue_free()
