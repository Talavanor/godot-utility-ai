# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
extends Node

@export var show_value_debug : bool = true
@export var target_agent : Agent
@export var value_debug_label : RichTextLabel

func _ready():
	# Gets the need via arbitrary name from node tree
	var needs: AgentNeeds = $Agent.needs

	# Connects all debug bars to the needs changed event
	needs.food_changed.connect(%FoodBar._on_needs_changed)
	needs.fun_changed.connect(%FunBar._on_needs_changed)
	needs.energy_changed.connect(%EnergyBar._on_needs_changed)

	$Agent.state_changed.connect(%StateLabel._on_state_changed)

	
	if show_value_debug:
		update_value_debug()



func update_value_debug() -> void:
	
	if not target_agent or not value_debug_label: return

	value_debug_label.text = ""

	# print option values for debug
	var highest_value: float = 0
	var best_option: UtilityAIOption
	for option in target_agent._options:
		var current_value: float = option.evaluate()
		value_debug_label.text += "%s value = %02f \n" % [option.action, current_value] # option.action + " value is " + str(current_value)
		if current_value > highest_value:
			highest_value = current_value
			best_option = option

	value_debug_label.text += "\n--- \n[color=green]Choice = %s \n> Value: %02f\n> Cooldown: %02d[/color]" % [best_option.action, highest_value, target_agent._time_until_next_decision]

	# As long as the debug toggle is on just keep re-running this method
	if show_value_debug:
		await get_tree().create_timer(0.1).timeout
		update_value_debug()