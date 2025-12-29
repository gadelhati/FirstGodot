# ============================================
# resources/wave_data.gd
# ============================================
class_name WaveData
extends Resource

@export var wave_number: int = 1
@export var enemy_spawns: Array[EnemySpawn] = []
@export var delay_before_wave: float = 3.0
@export var spawn_interval: float = 1.0

func get_total_enemies() -> int:
	var total = 0
	for spawn in enemy_spawns:
		total += spawn.count
	return total
