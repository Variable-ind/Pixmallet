class_name BaseLayer extends RefCounted
# Base class for layer properties. Different layer types extend from this class.

var name := ''
var index : = 0
var opacity := 1.0
var parent :BaseLayer
var expanded :bool = false

var is_visible :bool = true
var is_locked :bool = false



func is_ancestor_of(layer: BaseLayer):
	# Returns true if this is a direct or indirect parent of layer
	if layer.parent == self:
		return true
	elif is_instance_valid(layer.parent):
		return is_ancestor_of(layer.parent)
	return false


func is_expanded_in_hierarchy() -> bool:
	if is_instance_valid(parent):
		return parent.expanded and parent.is_expanded_in_hierarchy()
	return true


func is_visible_in_hierarchy() -> bool:
	if is_instance_valid(parent) and is_visible:
		return parent.is_visible_in_hierarchy()
	return is_visible


func is_locked_in_hierarchy() -> bool:
	if is_instance_valid(parent) and not is_locked:
		return parent.is_locked_in_hierarchy()
	return is_locked


func get_hierarchy_depth() -> int:
	if is_instance_valid(parent):
		return parent.get_hierarchy_depth() + 1
	return 0


func get_layer_path() -> String:
	if is_instance_valid(parent):
		return str(parent.get_layer_path(), "/", name)
	return name


# Methods to Override:

func set_name_to_default(number: int):
	name = str(number)


func can_layer_get_drawn() -> bool:
	return false
