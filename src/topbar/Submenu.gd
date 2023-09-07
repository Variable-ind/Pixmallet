extends PopupMenu

signal item_pressed(item_data)

var data_dict: Dictionary = {}


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


func register(label, data, parent_menu):
	clear()  
	data_dict = {}
	# make sure all items are removed before new item inject.
	if parent_menu != get_parent():
		parent_menu.add_child(self)
		parent_menu.add_submenu_item(label, get_name())
	
	for i in data.size():
		var item = data[i]
		if item.get('key'):
			if item.has('check'):
				add_check_item(item['label'], i)
				set_item_checked(i, bool(item['check']))
			else:
				add_item(item['label'], i)
		item['index'] = i
		data_dict[i] = item


func _on_id_pressed(_id):
	var item = data_dict.get(_id)
	if item:
		# signel
		item_pressed.emit(item)
		
		# change ui element display
		if item.has('check'):
			item['check'] = not item.get('check')
			set_item_checked(item['index'], item['check'])
		else:
			hide()
			get_parent().hide()
