class_name ImageChangeHistory extends Node

var undo_redo = UndoRedo.new()
var count :int :
	get: return undo_redo.get_history_count()

var img_stack :Array[Dictionary] = []
var action_stack :Array[Callable] = []


func clear():
	undo_redo.clear_history()


func record(imgs:Variant, actions:Variant=null):
	imgs = prepare_imgs(imgs)
	actions = prepare_actions(actions)
	for img in imgs:
		img_stack.append({
			'img': img,
			'undo_data': img.data
		})
	for act in actions:
		action_stack.append(act)


func commit(action_name:String=''):
	undo_redo.create_action(action_name)
	
	for item in img_stack:
		undo_redo.add_do_property(item['img'], 'data', item['img'].data)
	for item in img_stack:
		undo_redo.add_undo_property(item['img'], 'data', item['undo_data'])
		
	for do_act in action_stack:
		undo_redo.add_do_method(do_act)
	for undo_act in action_stack:
		undo_redo.add_undo_method(undo_act)

	undo_redo.commit_action(false)
	img_stack.clear()
	action_stack.clear()


func undo():
	if undo_redo.has_undo():
		undo_redo.undo()


func redo():
	if undo_redo.has_redo():
		undo_redo.redo()


func prepare_imgs(imgs:Variant):
	if imgs is Image:
		return [imgs]
	elif imgs is Array:
		return imgs.filter(func(img): return img is Image)
	else:
		return []


func prepare_actions(actions:Variant):
	if actions is Callable:
		return [actions]
	elif actions is Array:
		return actions.filter(func(act): return act is Callable)
	else:
		return []



func gen_action_name():
	return '{}-{}'.format([Time.get_unix_time_from_system(),
						   randi_range(1000, 9999)], '{}')
