# ============================================
# components/ai_state_component.gd
# ============================================
class_name AIStateComponent
extends RefCounted

signal state_changed(old_state: String, new_state: String)

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	RETREAT
}

var current_state: State = State.IDLE
var owner: Node

func _init(p_owner: Node, initial_state: State = State.IDLE):
	owner = p_owner
	current_state = initial_state

func change_state(new_state: State):
	if new_state == current_state:
		return
	
	var old = State.keys()[current_state]
	current_state = new_state
	var new = State.keys()[new_state]
	
	state_changed.emit(old, new)

func is_state(state: State) -> bool:
	return current_state == state

func get_state() -> State:
	return current_state
