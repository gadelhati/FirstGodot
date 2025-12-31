# ============================================
# managers/wave_manager.gd
# ============================================
class_name WaveManager
extends Node

@export_group("Configuration")
@export var waves: Array[WaveData] = []
@export var time_limit: float = 150.0
@export var auto_start: bool = true

@export_group("Spawn Settings")
@export var spawn_around_player: bool = true
@export var min_spawn_distance: float = 200.0
@export var max_spawn_distance: float = 400.0
@export var spawn_parent_node: Node = null
@export var tilemap_layer: TileMapLayer = null
@export var spawn_margin: float = 50.0

@export_group("UI")
@export var wave_label: Label = null
@export var timer_label: Label = null
@export var enemy_counter: Label = null

var component: WaveManagerComponent

func _ready():
	component = WaveManagerComponent.new(self)
	_connect_signals()
	
	if spawn_parent_node:
		component.spawn_parent_override = spawn_parent_node
	
	component.spawn_around_player = spawn_around_player
	component.min_spawn_distance = min_spawn_distance
	component.max_spawn_distance = max_spawn_distance
	component.tilemap_layer = tilemap_layer
	component.spawn_margin = spawn_margin
	
	if not waves.is_empty():
		component.setup(waves, time_limit)
		
		if auto_start:
			start_waves()
	# Se não há ondas, assume que serão configuradas por código
	# Não mostra warning se auto_start está false

func _connect_signals():
	component.wave_started.connect(_on_wave_started)
	component.wave_completed.connect(_on_wave_completed)
	component.enemy_spawned.connect(_on_enemy_spawned)
	component.all_waves_completed.connect(_on_all_waves_completed)
	component.time_updated.connect(_on_time_updated)

func _process(delta):
	if component.is_wave_active():
		component.update(delta)
		_update_ui()

func _update_ui():
	if wave_label:
		wave_label.text = "Wave %d/%d" % [
			component.get_current_wave() + 1,
			component.get_total_waves()
		]
	
	if timer_label:
		var remaining = component.get_time_remaining()
		var minutes = floori(remaining / 60.0)
		var seconds = int(remaining) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	if enemy_counter:
		enemy_counter.text = "Enemies: %d" % component.get_active_enemy_count()

func start_waves():
	component.start()

func stop_waves():
	component.stop()

func add_wave(wave: WaveData):
	waves.append(wave)
	component.setup(waves, time_limit)

func get_current_wave() -> int:
	return component.get_current_wave()

func get_active_enemies() -> int:
	return component.get_active_enemy_count()

func _on_wave_started(wave_number: int, total_enemies: int):
	print("Wave %d iniciada! %d inimigos" % [wave_number, total_enemies])

func _on_wave_completed(wave_number: int):
	print("Wave %d completada!" % wave_number)

func _on_enemy_spawned(_enemy: Node2D, _wave_number: int):
	pass

func _on_all_waves_completed():
	print("Todas as ondas completadas!")

func _on_time_updated(current: float, total: float):
	if current >= total:
		print("Tempo esgotado!")
