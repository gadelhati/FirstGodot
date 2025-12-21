# ============================================
# COMPONENTES COMPARTILHADOS (components/damage_feedback_component.gd)
# ============================================
class_name DamageFeedbackComponent
extends RefCounted

var target_node: Node2D
var default_color: Color
var damage_color: Color
var flash_duration: float

func _init(p_target: Node2D, p_damage_color: Color = Color.RED, p_duration: float = 0.1):
	target_node = p_target
	default_color = target_node.modulate
	damage_color = p_damage_color
	flash_duration = p_duration

func play_feedback():
	if target_node == null:
		return
	
	target_node.modulate = damage_color
	await target_node.get_tree().create_timer(flash_duration).timeout
	target_node.modulate = default_color
