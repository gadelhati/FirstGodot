# ============================================
# resources/enemy_spawn.gd
# ============================================
class_name EnemySpawn
extends Resource

@export var enemy_scene: PackedScene
@export var count: int = 1
@export var spawn_points: Array[Vector2] = []
