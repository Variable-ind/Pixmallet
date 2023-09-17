extends Panel

class_name Navbar

signal navigation_to(navId, data)

enum {
	NEW_FILE, OPEN_FILE, RECENT_FILE, SAVE_FILE, SAVE_FILE_AS, EXPORT_FILE, QUIT,
	
	UNDO, REDO, COPY, PASTE, DELETE, PREFERENCES, 
	
	SELECT_ALL, CLEAR_SEL, INVERT_SEL,
	
	RESIZE_CANVAS, IMG_OFFSET, IMG_SCALE, IMG_CROP, IMG_FLIP, IMG_ROTATE, 
	IMG_OUTLINE, DROP_SHADOW, INVERT_COLOR, DESATURATION, HSV, POSTERIZE,
	GRADIENT,
	
	TILE_MODE, TILE_MODE_OFFSET, GRAYSCALE_VIEW, MIRROR_VIEW,
	SHOW_GRID, SHOW_PIX_GRID, SHOW_RULERS, SHOW_GUIDES, SHOW_MOUSE_GUIDES,
	SNAP_GROUP, SNAP_GRID,SNAP_GUIDES,SNAP_PRESPECTIVE,
	
	TOOLBAR, TIMELINE, CANVAS_PREVIEW,
	COLOR_PICKER, TOOL_OPTION, REFERENCE, PRESPECTIVE,
	
	SPLASH, SUPPORT, LOG_FOLDER, ABOUT,
}

var menu_item_map: Dictionary = {}


@onready var navbar_menus = [
	{
		'menu': $MenuItems/File,
		'popmenus': [
			{'id': NEW_FILE, 'label': 'New', 'action': 'new_file'},
			{'id': OPEN_FILE, 'label':'Open'},
			{'id': RECENT_FILE, 'label': 'Recent projects',
			 'submenu': $Submenu.duplicate(), 'unified': true, 'data': [
				{'label': 'file_path_1.file', 'path': 'file_path_1.file'},
				{'label': 'file_path_2.file', 'path': 'file_path_2.file'},
				{'label': 'file_path_2.file', 'path': 'file_path_2.file'},
			]},
			{'id': SAVE_FILE, 'label': 'Save'},
			{'id': SAVE_FILE_AS, 'label': 'Save as'},
			{'id': EXPORT_FILE, 'label': 'Export'},
			{'id': QUIT, 'label': 'Quit'},
		]
	},
	{
		'menu': $MenuItems/Edit,
		'popmenus': [
			{'id': UNDO, 'label': 'Undo'},
			{'id': REDO, 'label':'Redo'},
			{'id': COPY, 'label': 'Copy'},
			{'id': PASTE, 'label': 'Paste'},
			{'id': DELETE, 'label': 'Delete'},
			{'id': PREFERENCES, 'label': 'Preferences'},
		]
	},
	{
		'menu': $MenuItems/Select,
		'popmenus': [
			{'id': SELECT_ALL, 'label': 'All'},
			{'id': CLEAR_SEL, 'label':'Clear'},
			{'id': INVERT_SEL, 'label': 'Invert'},
#			{'key': 'tile_selection', 'label': 'On Tile'},
		]
	},
	{
		'menu': $MenuItems/Modify,
		'popmenus': [
			{'id': RESIZE_CANVAS, 'label': 'Resize Canvas'},
			{'id': IMG_OFFSET, 'label':'Offset Image'},
			{'id': IMG_SCALE, 'label': 'Scale Image'},
			{'id': IMG_CROP, 'label': 'Crop Image'},
			{'id': IMG_FLIP, 'label': 'Flip Image'},
			{'id': IMG_ROTATE, 'label': 'Rotate Image'},
			{'id': IMG_OUTLINE, 'label': 'Outline'},
			{'id': DROP_SHADOW, 'label': 'Drop Shadow'},
			{'id': INVERT_COLOR, 'label': 'Invert Colors'},
			{'id': DESATURATION, 'label': 'Desaturation'},
			{'id': HSV, 'label': 'Hue/Saturation/Value'},
			{'id': POSTERIZE, 'label': 'Posterize'},
			{'id': GRADIENT, 'label': 'Gradient'},
		]
	},
	{
		'menu': $MenuItems/View,
		'popmenus': [
			{'id': TILE_MODE, 'label': 'Tile Mode'},
			{'id': TILE_MODE, 'label':'Tile Mode Offset'},
			{'id': GRAYSCALE_VIEW, 'label': 'Grayscale View'},
			{'id': MIRROR_VIEW, 'label': 'Mirror View'},
			{'id': SHOW_GRID, 'label': 'Show Grid'},
			{'id': SHOW_PIX_GRID, 'label': 'Show Pixel Grid'},
			{'id': SHOW_RULERS, 'label': 'Show Rulers'},
			{'id': SHOW_GUIDES, 'label': 'Show Guides'},
			{'id': SHOW_MOUSE_GUIDES, 'label': 'Show Mouse Guides'},
			{'id': SNAP_GROUP, 'label': 'Snap To', 'submenu': $Submenu.duplicate(),
			 'data': [
				{'id': SNAP_GRID, 'label':'Grids', 'check': false},
				{'id': SNAP_GUIDES, 'label':'Guides', 'check': false},
				{'id': SNAP_PRESPECTIVE, 'label':'Perspective Guides',
				 'check': false}
			]},
		]
	},
	{
		'menu': $MenuItems/Window,
		'popmenus': [
#			{'key': 'toogle_canvas_only', 'label': 'Toogle Canvas Only'},
			{'id': TOOLBAR, 'label': 'Tools', 'check': true},
			{'id': TIMELINE, 'label': 'Animation Timeline', 'check': true},
			{'id': CANVAS_PREVIEW, 'label': 'Canvas Preview', 'check': true},
			{'id': COLOR_PICKER, 'label': 'Color Pickers', 'check': true},
			{'id': TOOL_OPTION, 'label': 'Tool Options', 'check': true},
			{'id': REFERENCE, 'label': 'Reference Images', 'check': false},
			{'id': PRESPECTIVE, 'label': 'Perspective Editor', 'check': false},
		]
	},
	{
		'menu': $MenuItems/Help,
		'popmenus': [
			{'id': SPLASH, 'label': 'Splash Screen'},
			{'id': SUPPORT, 'label':'Support'},
			{'id': LOG_FOLDER, 'label': 'Logs'},
			{'id': ABOUT, 'label': 'About'},
		]
	}
]


func _ready():
	for menu in navbar_menus:
		_set_menu_items(menu['menu'], menu['popmenus'])


func _set_menu_items(menu:MenuButton, structure:Array):
	var menu_popup = menu.get_popup()
	menu_popup.id_pressed.connect(_on_menu_id_pressed)
	
	for i in structure.size():
		var item = structure[i]
		if item.get('submenu'):
			var rediect_id = item['id'] if item.get('unified') else -1
			item['submenu'].register(item['label'], item.get('data', []),
									 menu_popup, rediect_id)
		else:
			if item.has('check'):
				menu_popup.add_check_item(item['label'], item['id'])
				menu_popup.set_item_checked(i, bool(item['check']))
				menu_popup.hide_on_checkable_item_selection = false
			else:
				menu_popup.add_item(item['label'], item['id'])
			if item.get('action'):
				var shortcut:Shortcut = Shortcut.new()
#				var event:InputEventAction = InputEventAction.new()
#				var event_action:StringName = ACTION_NAME_TMPL.format(
#					{'n': item['action']}) 
#				event.action = item.get('event', event_action)
#				shortcut.events.append(event)
#				menu_popup.set_item_shortcut(i, shortcut)
		
		# record menu item to k, v map
		item['popup'] = menu_popup
		item['index'] = i
		menu_item_map[item['id']] = item


func _on_menu_id_pressed(item_id):
	var item_data = menu_item_map.get(item_id)
	var menu_popup = item_data['popup']
	var idx = item_data['index']
	
	if item_data.has('check'):
		item_data['check'] = not item_data.get('check')
		menu_popup.set_item_checked(idx, item_data['check'])
	
	navigation_to.emit(item_id, item_data)


func _on_submenu_item_pressed(item_id, item_data):
	navigation_to.emit(item_id, item_data)

