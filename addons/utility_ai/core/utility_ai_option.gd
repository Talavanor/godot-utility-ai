# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: MIT
@tool
class_name UtilityAIOption
extends Resource
## Describes a single option to evaluate.
##
## An option pairs a [member behavior] with the specific decision
## [member context] in which it should be evaluated. An option can also store
## an optional [member action] that should be triggered in the event that this
## option is chosen.

## The behavior that will drive the evaluation of this option's utility.
@export var behavior: UtilityAIBehavior

## The specific decision context that should be used to evaluate this option.
## [br][br]
## [b]Note[/b]: Anything can be used as a decision context, as long as it
## provides a [code]get()[/code] method that allows considerations to look-up
## the values of input values. Common examples include: a [Resource]
## describing an agent's state, or a [Dictionary] mapping input keys to input
## values.
var context: Variant = null

## An optional value describing any action(s) that should be triggered in the
## event that this option is chosen.
## [br][br]
## [b]Note[/b]: This variable is not used by the plugin, but can be used to
## associate a [UtilityAIOption] with an action. Anything can be used as an
## action, but common examples include: a [Callable] that directly affects
## gameplay, a [Dictionary] of values to pass to some other function, or a
## [Resource] describing the chosen action.
var action: Variant

# func _init(
# 	p_behavior: UtilityAIBehavior = behavior,
# 	p_context:= context,
# 	p_action := action
# ):
# 	behavior = p_behavior
# 	context = p_context
# 	action = p_action



## Calculate the utility of this option, using [member behavior] and
## [member context]. Equivalent to calling:
## [code]behavior.evaluate(context)[/code].
func evaluate() -> float:
	return behavior.evaluate(context)


func _to_string() -> String:
	return (
		"[<UtilityAIOption#%d>: %s, %s, %s]"
		% [self.get_instance_id(), action, behavior, context]
	)


# The fake "action_type" property exposed by _set, _get and _get_property_list()
# is a workaround for the lack of Inspector support for editing Variant
func _set(property: StringName, value: Variant) -> bool:
	if property == "action_type":
		match value:
			TYPE_NIL:
				action = null
			TYPE_STRING:
				action = String()
			TYPE_OBJECT:
				action = Object.new()
			TYPE_DICTIONARY:
				action = Dictionary()
			TYPE_ARRAY:
				action = Array()
			TYPE_CALLABLE:
				action = String()
		notify_property_list_changed()
		return true
	return false


func _get(property: StringName) -> Variant:
	if property == "action_type":
		return typeof(action)
	return null


func _get_property_list():
	var properties = []

	# This uses the agent class as a hard-coded source for possible methods
	var agent_actions := Agent.new().get_method_list()
	var agent_actions_hint : String
	var loop_index : int = 0
	for method in agent_actions:
		if "option_" in method["name"]:
			agent_actions_hint += (method["name"] + ",") #(method["name"] + ":" + str(loop_index) + ",")
			loop_index += 1
	agent_actions_hint = agent_actions_hint.left(-1)
	#print(agent_actions_hint)
	properties.append(
		{
			"name": "action_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Variant:0,Agent Method:4,Object:24,Dictionary:27,Array:28"
		}
	)

	# IF we're using a string then we pre-populate it with methods available to the agent class
	if typeof(get("action")) != TYPE_STRING:
		properties.append(
			{
				"name": "action",
				"type": get("action_type"),
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_NIL_IS_VARIANT,
				"hint": PROPERTY_HINT_NONE,
			}
		)
	else:
		properties.append(
			{
				"name": "action",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM_SUGGESTION,
				"hint_string": agent_actions_hint,
			}
		)
		print("Agent Action = " + action)
	return properties
