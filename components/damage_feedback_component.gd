# ============================================
# components/damage_feedback_component.gd
# ============================================
class_name DamageFeedbackComponent
extends RefCounted

var target: Node2D
var damage_color: Color
var duration: float

func _init(p_target: Node2D, color: Color = Color.RED, time: float = 0.1):
	target = p_target
	damage_color = color
	duration = time

func play():
	if not target:
		return
	
	var original = target.modulate
	target.modulate = damage_color
	await target.get_tree().create_timer(duration).timeout
	target.modulate = original
