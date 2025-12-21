# ============================================
# UI (UI/health_bar.gd)
# ============================================
class_name HealthBar
extends ProgressBar

@export var show_hp_text: bool = true
@export var use_color_transition: bool = true

var health_component: HealthComponent

func _ready():
	show_percentage = show_hp_text

func initialize(p_health_component: HealthComponent):
	health_component = p_health_component
	
	# Conecta aos sinais do componente
	health_component.health_changed.connect(_on_health_changed)
	
	# Atualiza valores iniciais
	_on_health_changed(
		health_component.get_current_hp(),
		health_component.get_max_hp()
	)

func _on_health_changed(current: float, maximum: float):
	max_value = maximum
	value = current
	
	if use_color_transition:
		update_color()

func update_color():
	var percentage = health_component.get_hp_percentage()
	
	if percentage > 60:
		modulate = Color.GREEN
	elif percentage > 30:
		modulate = Color.YELLOW
	else:
		modulate = Color.RED

# API Pública (para uso manual se necessário)
func set_hp(current: float, maximum: float):
	max_value = maximum
	value = current
	if use_color_transition:
		update_color()
