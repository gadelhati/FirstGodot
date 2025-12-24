# ============================================
# components/ai_state_component.gd
# ============================================
class_name AIStateComponent
extends RefCounted

signal state_changed(old: String, new: String)

enum State { IDLE, PATROL, CHASE, ATTACK, RETREAT }

var state: State
var owner: Node

func _init(p_owner: Node, initial: State = State.IDLE):
	owner = p_owner
	state = initial

func change(new_state: State):
	if new_state == state:
		return
	
	var old = State.keys()[state]
	state = new_state
	state_changed.emit(old, State.keys()[state])

func is_state(s: State) -> bool:
	return state == s

func current() -> State:  # ← MUDOU de get() para current()
	return state
