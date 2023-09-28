class_name NavSubmenu extends PopupMenu

signal item_pressed(item_data)

var data_dict: Dictionary = {}
var dynamic_data_stack: Array = []


func _ready():
	# BAD IDEA BUT IT's WORK.
	hide_on_item_selection = false
	hide_on_checkable_item_selection = false
	# hide menu manually to fix `window_get_popup_safe_rect` bug.'
	# Error is cause by both parent menu and submenu might disappear same time.
	# engine try to focus on a non exists menu object.
	# issues:
	# https://github.com/godotengine/godot/pull/76498
	# https://github.com/godotengine/godot/issues/73413
	# https://github.com/godotengine/godot/issues/76480
	# Error:
	# E 0:00:03:0055   window_get_popup_safe_rect: Condition "!windows.has(p_window)" 
	# is true. Returning: Rect2i()
	# <C++ Source>   platform/macos/display_server_macos.mm:3706 @ 
	# window_get_popup_safe_rect()


func register(label, data, parent_menu, redirect_id:int=-1):
	# use redirect_id to call same action with parent menu.
	
	clear()
	data_dict = {}
	dynamic_data_stack = []
	# make sure all items are removed before new item inject.
	if parent_menu != get_parent():
		parent_menu.add_child(self)
		parent_menu.add_submenu_item(label, get_name())
	
	for i in data.size():
		var item = data[i]
		
		if not item.get('id'):
			dynamic_data_stack.append(item)
			continue
			
		if item.has('check'):
			add_check_item(item['label'], item['id'])
			set_item_checked(i, bool(item['check']))
		else:
			add_item(item['label'], item['id'])
		
		# inject redirect id
		if redirect_id > -1:
			item['redirect_id'] = redirect_id
		
		item['index'] = i
		data_dict[item['id']] = item
	
	# fill none id item after others.
	if dynamic_data_stack.size() > 0:
		for d in dynamic_data_stack:
			append_item(d, redirect_id)



func append_item(item, redirect_id:int = -1):
	# append single item after registered.
	
	if not item.get('id'):
		item['id'] = _generate_item_id()
	
	if redirect_id > -1:
		item['redirect_id'] = redirect_id
		
	item['index'] = item_count
	
	if item.has('check'):
		add_check_item(item['label'], item['id'])
		set_item_checked(item['index'], bool(item['check']))
	else:
		add_item(item['label'], item['id'])
	
	data_dict[item['id']] = item
		

func _generate_item_id():
	# generate id by most largest id,
	# plus 10 to gap each other.
	
	var curr_id = 0
	for k in data_dict:
		var item = data_dict[k]
		if item['id'] > curr_id:
			curr_id = item['id']
	return curr_id + 10


func _on_id_pressed(item_id):
	var item_data = data_dict.get(item_id)
	if item_data:		
		# change ui element display
		if item_data.has('check'):
			item_data['check'] = not item_data.get('check')
			set_item_checked(item_data['index'], item_data['check'])
		else:
			hide()
			get_parent().hide()
		
		# redirect item_id, incase some item must call same parent action.
		if item_data.get('redirect_id', -1) > -1:
			item_id = item_data['redirect_id']
		
		# signel	
		item_pressed.emit(item_id, item_data)
