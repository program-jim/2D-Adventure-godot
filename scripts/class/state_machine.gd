####################
#
#	File Name: state_machine.gd
#	File Created Date: July 7 2025
#	Language: GDScript
#	File Description:
#		State machine to controll states of every movable and interected objects.
#
####################

class_name StateMachine
extends Node

const KEEP_CURRENT := -1

var state_time : float

var current_state : int = -1:
	set(v):
		owner.transition_state(current_state, v)
		current_state = v
		state_time = 0

func _ready() -> void:
	await owner.ready
	current_state = 0

func _physics_process(delta: float) -> void:
	while true:
		var next := owner.get_next_state(current_state) as int
		if next == KEEP_CURRENT:
			break
		else:
			current_state = next
			
			
	owner.tick_physics(current_state, delta)
	state_time += delta
		
