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
			{'key': 'quit', 'label': 'Quit', 'evt': QUIT},
		]
	},
	{
		'menu': $MenuItems/Edit,
		'popmenus': [
			{'key': 'undo', 'label': 'Undo', 'evt': EDIT},
			{'key': 'redo', 'label':'Redo', 'evt': EDIT},
			{'key': 'copy', 'label': 'Copy', 'evt': EDIT},
			{'key': 'paste', 'label': 'Paste', 'evt': EDIT},
			{'key': 'delete', 'label': 'Delete', 'evt': EDIT},
			{'key': 'preferences', 'label': 'Preferences'},
		]
	},
	{
		'menu': $MenuItems/Select,
		'popmenus': [
			{'key': 'select_all', 'label': 'All', 'evt': SELECT},
			{'key': 'clear_selection', 'label':'Clear', 'evt': SELECT},
			{'key': 'invert_selection', 'label': 'Invert', 'evt': SELECT},
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
			{'key': 'tile_mode', 'label': 'Tile Mode', 'evt': VIEW},
			{'key': 'tile_mode_offset', 'label':'Tile Mode Offset', 'evt': VIEW},
			{'key': 'grayscale_view', 'label': 'Grayscale View', 'evt': VIEW},
			{'key': 'mirror_view', 'label': 'Mirror View', 'evt': VIEW},
			{'key': 'show_grid', 'label': 'Show Grid', 'evt': VIEW},
			{'key': 'show_pixel_grid', 'label': 'Show Pixel Grid', 'evt': VIEW},
			{'key': 'show_rulers', 'label': 'Show Rulers', 'evt': VIEW},
			{'key': 'show_guides', 'label': 'Show Guides', 'evt': VIEW},
			{'key': 'show_mouse_guides', 'label': 'Show Mouse Guides', 'evt': VIEW},
			{'label': 'Snap To',
			 'submenu': $Submenu.duplicate(),
			 'data': [
				{'key':'snap_to_grid', 'label':'Grids', 
				 'check': true, 'evt': SNAP},
				{'key':'snap_to_guides', 'label':'Guides', 
				 'check': true, 'evt': SNAP},
				{'key':'snap_to_perspective', 'label':'Perspective Guides',
				 'check': true, 'evt': SNAP}
			]},
		]
	},
	{
		'menu': $MenuItems/Window,
		'popmenus': [
#			{'key': 'toogle_canvas_only', 'label': 'Toogle Canvas Only'},
			{'key': 'show_tools_panel', 'label': 'Tools', 
			 'check': true, 'evt': PANEL},
			{'key': 'show_timeline_panel', 'label': 'Animation Timeline',
			 'check': true, 'evt': PANEL},
			{'key': 'show_canvas_preview', 'label': 'Canvas Preview',
			 'check': true, 'evt': PANEL},
			{'key': 'show_color_picker', 'label': 'Color Pickers',
			 'check': true, 'evt': PANEL},
			{'key': 'show_tool_options', 'label': 'Tool Options',
			 'check': true, 'evt': PANEL},
			{'key': 'show_reference_image', 'label': 'Reference Images',
			 'check': false, 'evt': PANEL},
			{'key': 'show_perspective', 'label': 'Perspective Editor',
			 'check': false, 'evt': PANEL},
		]
	},
	{
		'menu': $MenuItems/Help,
		'popmenus': [
			{'key': 'open_splash_screen', 'label': 'Splash Screen', 'evt': SPLASH},
			{'key': 'open_online_support', 'label':'Support', 'evt': LINK},
			{'key': 'open_logs_folder', 'label': 'Logs', 'evt': FOLDER},
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

	match menu_item.get('evt'):
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
	match item_data.get('evt'):
		SNAP:
			print('snap -->', item_data['key'])
		_:
			open_project_file.emit(item_data['key'])
			print('open -->', item_data['key'])
