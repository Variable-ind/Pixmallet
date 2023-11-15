class_name History extends Node

enum {
	MERGE_DISABLE,
	MERGE_ENDS,  # use first action's undo , and use do of next same action.
	MERGE_ALL,  # merge to next same action.
}

static var undo_redo = UndoRedo.new()

static var count :int :
	get: return undo_redo.get_history_count()
	
static var current_action_id :int :
	get: return undo_redo.get_current_action()

static var current_action_name :String :
	get: return undo_redo.get_current_action_name()
	
static var version : int:
	get: return undo_redo.get_version()

static var properties_stack :Array[HistoryProp] = []
static var do_methods_stack :Array[Callable] = []
static var undo_methods_stack :Array[Callable] = []

static var default_callbacks :Dictionary = {}


static func clear_history():
	undo_redo.clear_history()
	

static func reset():
	properties_stack.clear()
	do_methods_stack.clear()
	undo_methods_stack.clear()


static func register_default_callbacks(_callbacks_map :Dictionary):
	for k in _callbacks_map:
		var callback = _callbacks_map[k]
		if (k is String or k is StringName) and callback is Callable:
			if k in ['_', '-', '*']:
				k = '_'
			default_callbacks[k] = callback


static func unregister_default_callbacks():
	default_callbacks.clear()


static func record(properties:Variant, actions:Variant=null, use_reset:=true):
	if use_reset:
		reset()

	for prop in prepare_properties(properties):
		properties_stack.append(prop)

	for act in prepare_methods(actions):
		match act.type:
			HistoryMethod.Type.DO:
				do_methods_stack.append(act.method)
			HistoryMethod.Type.UNDO:
				undo_methods_stack.append(act.method)
			_:
				do_methods_stack.append(act.method)
				undo_methods_stack.append(act.method)


static func commit(action_name:StringName = '', merge := MERGE_DISABLE):
	var merge_mode
	
	match merge:
		MERGE_DISABLE:
			merge_mode = UndoRedo.MERGE_DISABLE
		MERGE_ENDS:
			merge_mode = UndoRedo.MERGE_ENDS
		MERGE_ALL:
			merge_mode = UndoRedo.MERGE_ALL

	undo_redo.create_action(action_name, merge_mode)
	
	for prop in properties_stack:
		undo_redo.add_do_property(prop.obj, prop.key, prop.do_value)
	
	for prop in properties_stack:
		undo_redo.add_undo_property(prop.obj, prop.key, prop.undo_value)
	
	var callbacks = get_default_callbacks(action_name)
	
	for do_act in do_methods_stack:
		undo_redo.add_do_method(do_act)
	
	for c in callbacks:
		undo_redo.add_do_method(c)
	
	for undo_act in undo_methods_stack:
		undo_redo.add_undo_method(undo_act)
	
	for c in callbacks:
		undo_redo.add_undo_method(c)

	undo_redo.commit_action(false)
	reset()


static func compose(action_name :StringName = '',
					properties = null,
					actions = null):
	record(properties, actions)
	commit(action_name)


static func undo():
	if undo_redo.has_undo():
		undo_redo.undo()


static func redo():
	if undo_redo.has_redo():
		undo_redo.redo()


static func has_redo():
	return undo_redo.has_redo()
	

static func has_undo():
	return undo_redo.has_undo()



static func prepare_properties(objs:Variant):
	var props :Array = []
	if objs is Image or objs is Dictionary:
		objs = [objs]
	elif not objs is Array:
		return props
	for obj in objs:
		if obj is Image:
			props.append(HistoryProp.new(obj, 'data'))
		elif obj is Dictionary:
			var prop = HistoryProp.new(obj['obj'], obj['key'])
			if obj.has('undo'):
				prop.undo_value = obj.get('undo')
			props.append(prop)
	return props


static func prepare_methods(funcs:Variant):
	var methods :Array = []
	
	if funcs is Callable or funcs is Dictionary:
		funcs = [funcs]
	elif not funcs is Array:
		return methods
	
	for fn in funcs:
		if fn is Callable:
			methods.append(HistoryMethod.new(fn))
		elif fn is Dictionary:
			if fn.get('all') is Callable:
				methods.append(
					HistoryMethod.new(fn['all'], HistoryMethod.Type.ALL))
			if fn.get('do') is Callable:
				methods.append(
					HistoryMethod.new(fn['do'], HistoryMethod.Type.DO))
			if fn.get('undo') is Callable:
				methods.append(
					HistoryMethod.new(fn['undo'], HistoryMethod.Type.UNDO))
	return methods


static func get_default_callbacks(key):
	var output := []
	for k in default_callbacks:
		if k == '_' or key.begins_with(key):
			output.append(default_callbacks[k])
	return output


func gen_action_name():
	return '{}-{}'.format([Time.get_unix_time_from_system(),
						   randi_range(1000, 9999)], '{}')


class HistoryProp extends Object:
	
	var obj :Variant
	var key :StringName
	var undo_value :Variant
	var do_value :Variant :
		get: return obj.get(key)
	
	func _init(_obj :Variant, _key :StringName):
		obj = _obj
		key = _key
		undo_value = obj.get(key)


class HistoryMethod extends Object:
	
	enum Type {
		ALL,
		DO,
		UNDO,
	}
	
	var method :Callable
	var type := Type.ALL
	
	func _init(_method :Callable, _type := Type.ALL):
		method = _method
		type = _type
