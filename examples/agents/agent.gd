# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
class_name Agent
extends Node2D

@export var show_value_debug : bool = true

signal state_changed(state)


enum State {
	NONE,
	EATING,
	SLEEPING,
	WATCHING_TV,
}


# Provides a needs resource that will dictate
@export var needs: AgentNeeds
var state: State = State.EATING


var _time_until_next_decision: int = 1



@export var option_resources: Array[UtilityAIOption]
@onready var _options : Array[UtilityAIOption] = option_resources

# NOTE: These SEEM to be in the onready instead of exported, because both the needs and the related
# callables needs to be passed into the init. Seems like this means that all bots would need to have
# their logic defined in code?
# @onready var _options: Array[UtilityAIOption] = [
# 	UtilityAIOption.new(
# 		preload("res://examples/agents/eat.tres"), needs, eat
# 	),
# 	UtilityAIOption.new(
# 		preload("res://examples/agents/sleep.tres"), needs, sleep
# 	),
# 	UtilityAIOption.new(
# 		preload("res://examples/agents/watch_tv.tres"), needs, watch_tv
# 	),
# ]

func _ready() -> void:
	for option in _options:
		option.context = needs


func option_eat():
	state = State.EATING
	_time_until_next_decision = 5
	state_changed.emit(state)


func option_sleep():
	state = State.SLEEPING
	_time_until_next_decision = 10
	state_changed.emit(state)


func option_watch_tv():
	state = State.WATCHING_TV
	_time_until_next_decision = 1
	state_changed.emit(state)




func _on_timer_timeout():

	# Adjust the agent's needs based on their state.
	# In a real project, this would be managed by something more sophisticated!
	if state == State.EATING:
		needs.food += 0.05
	else:
		needs.food -= 0.025

	if state == State.SLEEPING:
		needs.energy += 0.05
	else:
		needs.energy -= 0.025

	if state == State.WATCHING_TV:
		needs.fun += 0.05
	else:
		needs.fun -= 0.025

	# Check if the agent should change state.
	# Utility helps the agent decide what to do next, but the rules of the game
	# govern when those decisions should happen. In this example, each action
	# takes a certain amount of time to complete, but the agent will abandon
	# eating or sleeping when the associated needs bar is full.
	if (
		(state == State.SLEEPING and needs.energy == 1)
		or (state == State.EATING and needs.food == 1)
	):
		_time_until_next_decision = 0

	if _time_until_next_decision > 0:
		_time_until_next_decision -= 1
		return


	# Choose the action with the highest utility, and change state.
	var decision := UtilityAI.choose_highest(_options)
	
	# If we're dealing with a string, then we assume we're trying to call a method
	# We currently don't check if we have it because we're dynamically building the list and can 
	# ASSUME it exists
	if decision.action is String:
		if has_method(decision.action):
			var callable := Callable(self, decision.action)
			callable.call()
		#decision.action.call()
