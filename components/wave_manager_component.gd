# ============================================
# components/wave_manager_component.gd
# ============================================
class_name WaveManagerComponent
extends RefCounted

signal wave_started(wave_number: int, total_enemies: int)
signal wave_completed(wave_number: int)
signal enemy_spawned(enemy: Node2D, wave_number: int)
signal all_waves_completed()
signal time_updated(current: float, total: float)

var waves: Array[WaveData] = []
var current_wave_index: int = 0
var active_enemies: Array[Node2D] = []
var is_active: bool = false
var is_spawning: bool = false
var total_time: float = 0.0
var elapsed_time: float = 0.0
var owner_node: Node

var spawn_parent_override: Node = null
var spawn_around_player: bool = true
var min_spawn_distance: float = 200.0
var max_spawn_distance: float = 400.0

func _init(p_owner: Node):
	owner_node = p_owner

func setup(wave_list: Array[WaveData], time_limit: float = 300.0):
	waves = wave_list
	total_time = time_limit
	elapsed_time = 0.0
	current_wave_index = 0
	active_enemies.clear()

func start():
	if waves.is_empty():
		push_error("WaveManager: Nenhuma onda configurada!")
		return
	
	is_active = true
	_start_wave(current_wave_index)

func stop():
	is_active = false

func update(delta: float):
	if not is_active:
		return
	
	elapsed_time += delta
	time_updated.emit(elapsed_time, total_time)
	
	if elapsed_time >= total_time:
		_finish_all_waves()
		return
	
	# Apenas mantém a lista limpa
	_clean_dead_enemies()

func _start_wave(index: int):
	if index >= waves.size():
		all_waves_completed.emit()
		is_active = false
		return
	
	print("DEBUG: Iniciando onda index=", index, " de ", waves.size())
	
	var wave = waves[index]
	wave_started.emit(wave.wave_number, wave.get_total_enemies())
	
	if wave.delay_before_wave > 0:
		print("DEBUG: Aguardando delay de ", wave.delay_before_wave, "s")
		await owner_node.get_tree().create_timer(wave.delay_before_wave).timeout
	
	print("DEBUG: Chamando _spawn_wave_enemies")
	await _spawn_wave_enemies(wave)
	
	print("DEBUG: _spawn_wave_enemies completado, aguardando inimigos morrerem...")

func _spawn_wave_enemies(wave: WaveData):
	is_spawning = true
	print("DEBUG: Iniciando spawn da wave ", wave.wave_number)
	print("DEBUG: current_wave_index=", current_wave_index, " waves.size()=", waves.size())
	print("DEBUG: Total de grupos de spawn: ", wave.enemy_spawns.size())
	
	for enemy_spawn in wave.enemy_spawns:
		print("DEBUG: Spawnando ", enemy_spawn.count, " inimigos...")
		for i in enemy_spawn.count:
			_spawn_enemy(enemy_spawn)
			
			if i < enemy_spawn.count - 1:
				await owner_node.get_tree().create_timer(wave.spawn_interval).timeout
	
	print("DEBUG: Spawn da wave completo!")
	is_spawning = false
	
	# Agora que o spawn terminou, aguarda os inimigos serem derrotados
	_wait_for_wave_clear()

func _spawn_enemy(spawn_data: EnemySpawn):
	print("DEBUG: Tentando spawnar inimigo...")
	
	if not spawn_data.enemy_scene:
		push_error("WaveManager: enemy_scene não definido!")
		return
	
	if current_wave_index >= waves.size():
		push_error("WaveManager: current_wave_index fora dos limites!")
		return
	
	print("DEBUG: Instanciando cena: ", spawn_data.enemy_scene.resource_path)
	var enemy = spawn_data.enemy_scene.instantiate()
	
	if not enemy:
		push_error("WaveManager: Falha ao instanciar inimigo!")
		return
	
	var spawn_parent = spawn_parent_override if spawn_parent_override else owner_node.get_parent()
	if not spawn_parent:
		push_error("WaveManager: Não encontrou parent para spawnar inimigos!")
		enemy.queue_free()
		return
	
	print("DEBUG: Adicionando inimigo ao parent: ", spawn_parent.name)
	spawn_parent.add_child(enemy)
	
	var spawn_pos = _get_spawn_position(spawn_data)
	enemy.global_position = spawn_pos
	
	print("✓ Inimigo spawnado em: ", spawn_pos, " | Parent: ", spawn_parent.name)
	
	active_enemies.append(enemy)
	
	if enemy.has_signal("tree_exiting"):
		enemy.tree_exiting.connect(_on_enemy_died.bind(enemy))
	
	var wave_num = waves[current_wave_index].wave_number
	enemy_spawned.emit(enemy, wave_num)

func _get_spawn_position(spawn_data: EnemySpawn) -> Vector2:
	if not spawn_data.spawn_points.is_empty():
		return spawn_data.spawn_points.pick_random()
	
	if spawn_around_player:
		var spawn_center = Vector2.ZERO
		
		var player = _find_player()
		if player:
			spawn_center = player.global_position
		
		var angle = randf() * TAU
		var distance = randf_range(min_spawn_distance, max_spawn_distance)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		return spawn_center + offset
	
	var viewport = owner_node.get_viewport_rect()
	var margin = 50.0
	
	match randi() % 4:
		0:
			return Vector2(randf_range(0, viewport.size.x), -margin)
		1:
			return Vector2(viewport.size.x + margin, randf_range(0, viewport.size.y))
		2:
			return Vector2(randf_range(0, viewport.size.x), viewport.size.y + margin)
		_:
			return Vector2(-margin, randf_range(0, viewport.size.y))

func _find_player() -> Node2D:
	var root = owner_node.get_tree().root
	return _search_hero(root)

func _search_hero(node: Node) -> Node2D:
	if node is Hero:
		return node
	
	for child in node.get_children():
		var result = _search_hero(child)
		if result:
			return result
	
	return null

func _clean_dead_enemies():
	var alive: Array[Node2D] = []
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			alive.append(enemy)
	active_enemies = alive

func _on_enemy_died(enemy: Node2D):
	active_enemies.erase(enemy)

func _on_wave_cleared():
	var completed_wave = current_wave_index
	wave_completed.emit(waves[completed_wave].wave_number)
	
	current_wave_index += 1
	print("DEBUG: Onda ", completed_wave, " completada. Próximo index: ", current_wave_index)
	
	if current_wave_index < waves.size() and elapsed_time < total_time:
		_start_wave(current_wave_index)
	elif current_wave_index >= waves.size():
		_finish_all_waves()

func _wait_for_wave_clear():
	# Aguarda todos os inimigos serem derrotados
	while active_enemies.size() > 0:
		await owner_node.get_tree().create_timer(0.5).timeout
		_clean_dead_enemies()
	
	print("DEBUG: Todos os inimigos derrotados!")
	_on_wave_cleared()

func _finish_all_waves():
	is_active = false
	all_waves_completed.emit()

func get_current_wave() -> int:
	return current_wave_index

func get_total_waves() -> int:
	return waves.size()

func get_active_enemy_count() -> int:
	return active_enemies.size()

func get_time_remaining() -> float:
	return max(0, total_time - elapsed_time)

func get_time_percentage() -> float:
	return (elapsed_time / total_time) * 100.0 if total_time > 0 else 0.0

func is_wave_active() -> bool:
	return is_active
