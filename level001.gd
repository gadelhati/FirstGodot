# ============================================
# Exemplo de uso em uma cena (level_1.gd)
# ============================================
extends Node2D

const ENEMY_BASIC = preload("res://scene/enemy.tscn")

var wave_manager: WaveManager

func _ready():
	wave_manager = get_node("WaveManager")
	
	# Desliga o auto_start do WaveManager no Inspector!
	# Ou configure as ondas ANTES dele iniciar
	
	_configure_waves()
	
	# Pequeno delay para garantir que tudo está pronto
	await get_tree().create_timer(0.5).timeout
	wave_manager.start_waves()

func _configure_waves():
	print("Configurando ondas...")
	
	var wave1 = WaveData.new()
	wave1.wave_number = 1
	wave1.delay_before_wave = 2.0
	wave1.spawn_interval = 1.0
	
	var spawn1 = EnemySpawn.new()
	spawn1.enemy_scene = ENEMY_BASIC
	spawn1.count = 5
	wave1.enemy_spawns.append(spawn1)
	
	var wave2 = WaveData.new()
	wave2.wave_number = 2
	wave2.delay_before_wave = 5.0
	wave2.spawn_interval = 0.8
	
	var spawn2 = EnemySpawn.new()
	spawn2.enemy_scene = ENEMY_BASIC
	spawn2.count = 8
	wave2.enemy_spawns.append(spawn2)
	
	var wave3 = WaveData.new()
	wave3.wave_number = 3
	wave3.delay_before_wave = 10.0
	wave3.spawn_interval = 1.5
	
	var spawn3 = EnemySpawn.new()
	spawn3.enemy_scene = ENEMY_BASIC
	spawn3.count = 12
	wave3.enemy_spawns.append(spawn3)
	
	wave_manager.add_wave(wave1)
	wave_manager.add_wave(wave2)
	wave_manager.add_wave(wave3)
	
	print("Ondas configuradas: ", wave_manager.component.get_total_waves())
