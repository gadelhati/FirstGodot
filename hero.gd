extends CharacterBody2D

# Configurações de movimento
@export var speed: float = 300.0

# Sistema de HP
@export var max_hp: float = 100.0
var current_hp: float = 100.0

# Configurações de tiro
@export var bullet_speed: float = 500.0
@export var max_bullet_distance: float = 1000.0
@export var fire_rate: float = 0.2  # Tempo entre disparos em segundos

# Cena do projétil (você precisa criar e atribuir no Inspector)
@export var bullet_scene: PackedScene

# Ponto de spawn opcional (deixe vazio para usar o centro do CharacterBody2D)
@export var spawn_point: Node2D

var can_shoot: bool = true

func _ready():
	current_hp = max_hp

func get_current_hp() -> float:
	return current_hp

func get_max_hp() -> float:
	return max_hp

func take_damage(damage: float):
	current_hp -= damage
	current_hp = clamp(current_hp, 0, max_hp)
	
	# Feedback visual
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_hp <= 0:
		die()

func die():
	print("Game Over!")
	# Aqui você pode adicionar tela de game over
	get_tree().reload_current_scene()

func _physics_process(delta):
	# === MOVIMENTAÇÃO ===
	# Captura entrada do teclado
	var input_vector = Vector2.ZERO
	
	# Teclas WASD para movimentação
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	
	# Normaliza o vetor para movimento diagonal não ser mais rápido
	input_vector = input_vector.normalized()
	
	# Define a velocidade
	velocity = input_vector * speed
	
	# Move o personagem
	move_and_slide()
	
	# === TIRO ===
	# Verifica se o botão esquerdo do mouse foi pressionado
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if bullet_scene == null:
		push_error("Cena do projétil não foi atribuída!")
		return
	
	# Desabilita tiro temporariamente
	can_shoot = false
	
	# Define a posição de origem (usa spawn_point se definido, senão usa o centro do character)
	var origin_pos = spawn_point.global_position if spawn_point else global_position
	
	# Calcula a direção para o cursor do mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - origin_pos).normalized()
	
	# Cria o projétil
	var bullet = bullet_scene.instantiate()
	
	# Posiciona o projétil à frente do personagem na direção exata do mouse
	var spawn_distance = 80.0  # Aumentado para evitar colisão
	var spawn_position = origin_pos + (direction * spawn_distance)
	
	# Adiciona o projétil à cena principal DEPOIS de calcular a posição
	get_parent().add_child(bullet)
	
	# Define a posição global do projétil
	bullet.global_position = spawn_position
	
	# Configura o projétil com a direção calculada
	bullet.setup(direction, bullet_speed, max_bullet_distance)
	
	# Timer para controlar taxa de disparo
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
