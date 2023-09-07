extends Panel

signal open_project_file(file_path)
signal open_modeal(key)

enum {
	MODEL,
	EDIT,
	SELECT,
	VIEW,
	SNAP,
	LINK,
	PANEL,
	SPLASH,
	FOLDER,
	QUIT,
}

@onready var topbar_menus = [
	{
		'menu': $MenuItems/File,
		'popmenus': [
			{'key': 'new_file', 'label': 'New'},
			{'key': 'open_file', 'label':'Open'},
			{'label': 'Recent projects',
			 'submenu': $Submenu.duplicate(),
			 'data': []},
			{'key': 'save_file', 'label': 'Save'},
			{'key': 'save_file_as', 'label': 'Save as'},
			{'key': 'export_file', 'label': 'Export'},
			{'key': 'quit', 'label': 'Quit', 'type': QUIT},
		]
	},
	{
		'menu': $MenuItems/Edit,
		'popmenus': [
			{'key': 'undo', 'label': 'Undo', 'type': EDIT},
			{'key': 'redo', 'label':'Redo', 'type': EDIT},
			{'key': 'copy', 'label': 'Copy', 'type': EDIT},
			{'key': 'paste', 'label': 'Paste', 'type': EDIT},
			{'key': 'delete', 'label': 'Delete', 'type': EDIT},
			{'key': 'preferences', 'label': 'Preferences'},
		]
	},
	{
		'menu': $MenuItems/Select,
		'popmenus': [
			{'key': 'select_all', 'label': 'All', 'type': SELECT},
			{'key': 'clear_selection', 'label':'Clear', 'type': SELECT},
			{'key': 'invert_selection', 'label': 'Invert', 'type': SELECT},
#			{'key': 'tile_selection', 'label': 'On Tile'},
		]
	},
	{
		'menu': $MenuItems/Modify,
		'popmenus': [
			{'key': 'reisze_canvas', 'label': 'Resize Canvas'},
			{'key': 'offset_image', 'label':'Offset Image'},
			{'key': 'scale_image', 'label': 'Scale Image'},
			{'key': 'crop_image', 'label': 'Crop Image'},
			{'key': 'flip_image', 'label': 'Flip Image'},
			{'key': 'rotate_image', 'label': 'Rotate Image'},
			{'key': 'outline', 'label': 'Outline'},
			{'key': 'drop_shadow', 'label': 'Drop Shadow'},
			{'key': 'invert_colors', 'label': 'Invert Colors'},
			{'key': 'desaturation', 'label': 'Desaturation'},
			{'key': 'adjust_hsv', 'label': 'Hue/Saturation/Value'},
			{'key': 'posterize', 'label': 'Posterize'},
			{'key': 'gradient', 'label': 'Gradient'},
		]
	},
	{
		'menu': $MenuItems/View,
		'popmenus': [
			{'key': 'tile_mode', 'label': 'Tile Mode', 'type': VIEW},
			{'key': 'tile_mode_offset', 'label':'Tile Mode Offset', 'type': VIEW},
			{'key': 'grayscale_view', 'label': 'Grayscale View', 'type': VIEW},
			{'key': 'mirror_view', 'label': 'Mirror View', 'type': VIEW},
			{'key': 'show_grid', 'label': 'Show Grid', 'type': VIEW},
			{'key': 'show_pixel_grid', 'label': 'Show Pixel Grid', 'type': VIEW},
			{'key': 'show_rulers', 'label': 'Show Rulers', 'type': VIEW},
			{'key': 'show_guides', 'label': 'Show Guides', 'type': VIEW},
			{'key': 'show_mouse_guides', 'label': 'Show Mouse Guides', 'type': VIEW},
			{'label': 'Snap To',
			 'submenu': $Submenu.duplicate(),
			 'data': [
				{'key':'snap_to_grid', 'label':'Grids', 
				 'check': true, 'type': SNAP},
				{'key':'snap_to_guides', 'label':'Guides', 
				 'check': true, 'type': SNAP},
				{'key':'snap_to_perspective', 'label':'Perspective Guides',
				 'check': true, 'type': SNAP}
			]},
		]
	},
	{
		'menu': $MenuItems/Window,
		'popmenus': [
#			{'key': 'toogle_canvas_only', 'label': 'Toogle Canvas Only'},
			{'key': 'show_tools_panel', 'label': 'Tools', 
			 'check': true, 'type': PANEL},
			{'key': 'show_timeline_panel', 'label': 'Animation Timeline',
			 'check': true, 'type': PANEL},
			{'key': 'show_canvas_preview', 'label': 'Canvas Preview',
			 'check': true, 'type': PANEL},
			{'key': 'show_color_picker', 'label': 'Color Pickers',
			 'check': true, 'type': PANEL},
			{'key': 'show_tool_options', 'label': 'Tool Options',
			 'check': true, 'type': PANEL},
			{'key': 'show_reference_image', 'label': 'Reference Images',
			 'check': false, 'type': PANEL},
			{'key': 'show_perspective', 'label': 'Perspective Editor',
			 'check': false, 'type': PANEL},
		]
	},
	{
		'menu': $MenuItems/Help,
		'popmenus': [
			{'key': 'open_splash_screen', 'label': 'Splash Screen', 'type': SPLASH},
			{'key': 'open_online_support', 'label':'Support', 'type': LINK},
			{'key': 'open_logs_folder', 'label': 'Logs', 'type': FOLDER},
			{'key': 'about', 'label': 'About'},
		]
	}
]

var menu_item_map: Dictionary = {}


func _ready():
	var next_id = 0
	for menu in topbar_menus:
		next_id = _set_menu_items(menu['menu'], menu['popmenus'], next_id)


func _set_menu_items(menu:MenuButton, structure:Array, next_id:int=-1):
	var menu_popup = menu.get_popup()
	menu_popup.id_pressed.connect(_on_menu_id_pressed)
	
	for i in structure.size():
		var item = structure[i]
		if item.get('key'):
			if item.has('check'):
				menu_popup.add_check_item(item['label'], next_id)
				menu_popup.set_item_checked(i, bool(item['check']))
				menu_popup.hide_on_checkable_item_selection = false
			else:
				menu_popup.add_item(item['label'], next_id)
			if not item.get('skip_shortcut'):
				var shortcut = Shortcut.new()
				var event  = InputEventAction.new()
				event.action = item['key']
				shortcut.events.append(event)
				menu_popup.set_item_shortcut(i, shortcut)
		elif item.get('submenu'):
			item['submenu'].register(item['label'], item.get('data', []), menu_popup)
		
		# record menu item to k, v map
		item['popup'] = menu_popup
		item['index'] = i
		menu_item_map[next_id] = item
		
		# continue the _id for next loop.
		next_id += 1

	return next_id


func _on_menu_id_pressed(item_id):
	var menu_item = menu_item_map.get(item_id)
	var menu_popup = menu_item['popup']
	var idx = menu_item['index']

	match menu_item.get('type'):
		EDIT: 
			pass
		SELECT:
			pass
		VIEW:
			pass
		LINK:
			pass
		PANEL:
			menu_item['check'] = not menu_item.get('check')
			menu_popup.set_item_checked(idx, menu_item['check'])
		SPLASH:
			pass
		FOLDER:
			pass
		QUIT:
			pass
		_:
			open_modeal.emit(menu_item['key'])


func _on_submenu_item_pressed(item_data):
	match item_data.get('type'):
		SNAP:
			print('snap -->', item_data['key'])
		_:
			open_project_file.emit(item_data['key'])
			print('open -->', item_data['key'])
