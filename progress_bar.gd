extends ProgressBar

# Referência ao jogador
@export var player: CharacterBody2D

func _ready():
	if player and player.has_method("get_max_hp"):
		max_value = 100
		value = 100

func _process(delta):
	if player and player.has_method("get_current_hp"):
		var current = player.get_current_hp()
		var maximum = player.get_max_hp()
		value = (current / maximum) * 100
