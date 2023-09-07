extends Panel

signal open_project_file
signal open_section

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
			{'key': 'quit', 'label': 'Quit'},
		]
	},
	{
		'menu': $MenuItems/Edit,
		'popmenus': [
			{'key': 'undo', 'label': 'Undo'},
			{'key': 'redo', 'label':'Redo'},
			{'key': 'copy', 'label': 'Copy'},
			{'key': 'paste', 'label': 'Paste'},
			{'key': 'delete', 'label': 'Delete'},
			{'key': 'preferences', 'label': 'Preferences'},
		]
	},
	{
		'menu': $MenuItems/Select,
		'popmenus': [
			{'key': 'select_all', 'label': 'All'},
			{'key': 'clear_selection', 'label':'Clear'},
			{'key': 'invert_selection', 'label': 'Invert'},
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
			{'key': 'tile_mode', 'label': 'Tile Mode'},
			{'key': 'tile_mode_offset', 'label':'Tile Mode Offset'},
			{'key': 'grayscale_view', 'label': 'Grayscale View'},
			{'key': 'mirror_view', 'label': 'Mirror View'},
			{'key': 'show_grid', 'label': 'Show Grid'},
			{'key': 'show_pixel_grid', 'label': 'Show Pixel Grid'},
			{'key': 'show_rulers', 'label': 'Show Rulers'},
			{'key': 'show_guides', 'label': 'Show Guides'},
			{'key': 'show_mouse_guides', 'label': 'Show Mouse Guides'},
			{'label': 'Snap To',
			 'submenu': $Submenu.duplicate(),
			 'data': [
				{'key':'snap_to_grid', 'label':'Grids', 'check': true},
				{'key':'snap_to_guides', 'label':'Guides', 'check': true},
				{'key':'snap_to_perspective', 'label':'Perspective Guides',
				 'check': true}
			]},
		]
	},
	{
		'menu': $MenuItems/Window,
		'popmenus': [
#			{'key': 'toogle_canvas_only', 'label': 'Toogle Canvas Only'},
			{'key': 'show_tools_panel', 'label': 'Tools', 
			 'check': true},
			{'key': 'show_timeline_panel', 'label': 'Animation Timeline',
			 'check': true},
			{'key': 'show_canvas_preview', 'label': 'Canvas Preview',
			 'check': true},
			{'key': 'show_color_picker', 'label': 'Color Pickers',
			 'check': true},
			{'key': 'show_tool_options', 'label': 'Tool Options',
			 'check': true},
			{'key': 'show_reference_image', 'label': 'Reference Images',
			 'check': false},
			{'key': 'show_perspective', 'label': 'Perspective Editor',
			 'check': false},
		]
	},
	{
		'menu': $MenuItems/Help,
		'popmenus': [
			{'key': 'open_splash_screen', 'label': 'Splash Screen'},
			{'key': 'open_online_support', 'label':'Support'},
			{'key': 'open_logs_folder', 'label': 'Logs'},
			{'key': 'about', 'label': 'About'},
		]
	}
]



func _ready():
	for menu in topbar_menus:
		_set_menu_items(menu['menu'], menu['popmenus'])


func _set_menu_items(menu:MenuButton, structure:Array):
	var menu_popup = menu.get_popup()
	menu_popup.index_pressed.connect(_on_popup_menu_index_pressed)
	
	for i in structure.size():		
		var item = structure[i]
		if item.get('key'):
			if item.has('check'):
				menu_popup.add_check_item(item['label'], i)
				menu_popup.set_item_checked(i, bool(item['check']))
				menu_popup.hide_on_checkable_item_selection = false
			else:
				menu_popup.add_item(item['label'], i)
			if not item.get('skip_shortcut'):
				var shortcut = Shortcut.new()
				var event  = InputEventAction.new()
				event.action = item['key']
				shortcut.events.append(event)
				menu_popup.set_item_shortcut(i, shortcut)
		elif item.get('submenu'):
			item['submenu'].register(item['label'], item.get('data', []), menu_popup)


func _on_popup_menu_index_pressed(test):
	print(test)



func _on_submenu_item_pressed(item_data):
	if item_data.get('action') == 'open_file':
		open_project_file.emit(item_data['key'])
		print('open -->', item_data['key'])
	else:
		print(item_data['key'])
