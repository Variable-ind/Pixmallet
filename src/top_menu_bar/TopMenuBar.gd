extends Panel

signal signal_open_recent_projects

@onready var menuFile = $MenuItems/File

@onready var menu_file_items = [
	{'key': 'new_file', 'name': 'New'},
	{'key': 'open_file', 'name':'Open'},
	{'recent': true, 'name': 'Recent projects'},
	{'key': 'save_file', 'name': 'Save'},
	{'key': 'save_file_as', 'name': 'Save as'},
	{'key': 'export_file', 'name': 'Export'},
	{'key': 'quit', 'name': 'Quit'},
]

var submenu_recent_projects = PopupMenu.new()



func _ready():
	_set_menu_items(menuFile, menu_file_items)


func _set_menu_items(menu:MenuButton, structure:Array):
	var menu_popup = menu.get_popup()
	menu_popup.index_pressed.connect(_on_popup_menu_index_pressed)
	
	for i in structure.size():		
		var item = structure[i]
		if item.get('key'):
			menu_popup.add_item(item['name'], i)
			var shortcut = Shortcut.new()
			var event  = InputEventAction.new()
			event.action = item['key']
			shortcut.events.append(event)
			menu_popup.set_item_shortcut(i, shortcut)
		elif item.get('recent'):
			update_recent_projects_submenu(submenu_recent_projects)
			submenu_recent_projects.id_pressed.connect(_on_recent_projects_index_pressed)
#			submenu.unfocusable = true
			menu_popup.add_child(submenu_recent_projects)
			menu_popup.add_submenu_item(item['name'], submenu_recent_projects.get_name())


func update_recent_projects_submenu(submenu:PopupMenu):
	submenu.clear()  # make sure all items are removed before new item inject.
#	var recent_projects = g.get_data("recent_projects", []).reverse()
#	for project in recent_projects:
#		submenu.add_item(project.get_file())
	submenu.add_item('Test 1', 1)
	submenu.add_item('Test 2', 2)
	submenu.hide_on_item_selection = false  # NEED IT!
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




func _on_popup_menu_index_pressed(index, submenu):
	print('fuck', index, submenu)


func _on_recent_projects_index_pressed(index):
	signal_open_recent_projects.emit()
	submenu_recent_projects.hide() # manually hide menu because the bug above.


func _on_recent_projects_index_focused(index):
	pass


