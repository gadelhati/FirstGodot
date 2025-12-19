extends Area2D

var direction: Vector2
var speed: float
var max_distance: float
var traveled_distance: float = 0.0

@export var damage: float = 25.0  # Dano do projétil

func setup(dir: Vector2, spd: float, max_dist: float):
	direction = dir
	speed = spd
	max_distance = max_dist
	
	# Rotaciona o projétil na direção do movimento
	rotation = direction.angle()

func _physics_process(delta):
	# Move o projétil
	var movement = direction * speed * delta
	position += movement
	traveled_distance += movement.length()
	
	# Destroi se atingir distância máxima
	if traveled_distance >= max_distance:
		queue_free()

func _on_body_entered(body):
	# Verifica se o corpo tem o método take_damage (é um inimigo)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Destroi o projétil após colidir
	queue_free()

func _on_area_entered(area):
	# Detecta colisão com áreas
	queue_free()
