class_name Toolbar extends ScrollContainer

signal activated(operate_id)

const TOOL_ID_MAP: Dictionary = {
	'SelRect': Operate.SELECT_RECTANGLE,
	'SelEllipse': Operate.SELECT_ELLIPSE,
	'SelPolygon': Operate.SELECT_POLYGON,
	'SelLasso': Operate.SELECT_LASSO,
	'SelMagic': Operate.SELECT_MAGIC,
	'ShapeLine': Operate.SHAPE_LINE,
	'ShapeRect': Operate.SHAPE_RECTANGLE,
	'ShapeEllipse': Operate.SHAPE_ELLIPSE,
	'ShapePolygon': Operate.SHAPE_POLYGON,
	'Pencil': Operate.PENCIL,
	'Brush': Operate.BRUSH,
	'Erase': Operate.ERASE,
	'Bucket': Operate.BUCKET,
	'Move': Operate.MOVE,
	'ColorPick': Operate.COLORPICK,
	'Crop': Operate.CROP,
	'Zoom': Operate.ZOOM,
	'Pan': Operate.PAN,
	'Shading': Operate.SHADING,
}

var current_tool_name := ''

@onready var toolbtns = $ToolBtns
@onready var toolbar_keymaps = {
	'Select': {'action': 'select', 'event': KeyChain.makeEventKey(KEY_W)},
	'Shape': {'action': 'shape', 'event': KeyChain.makeEventKey(KEY_A)},
	'Draw': {'action': 'pencil', 'event': KeyChain.makeEventKey(KEY_B)},
	'Erase': {'action': 'erase', 'event': KeyChain.makeEventKey(KEY_E)},
	'Bucket': {'action': 'bucket', 'event': KeyChain.makeEventKey(KEY_G)},
	'Pan': {'action': 'pan', 'event': KeyChain.makeEventKey(KEY_SPACE)},
	'Move': {'action': 'move', 'event': KeyChain.makeEventKey(KEY_V)},
	'ColorPick': {'action':'colorpick', 'event': KeyChain.makeEventKey(KEY_I)},
	'Crop': {'action': 'crop', 'event': KeyChain.makeEventKey(KEY_C)},
	'Zoom': {'action': 'zoom', 'event': KeyChain.makeEventKey(KEY_Z)},
	'Shading': {'action': 'shading', 'event': KeyChain.makeEventKey(KEY_S)},
}


func _ready():
	for btn in toolbtns.get_children():
		if btn is Button:
			btn.pressed.connect(_on_button_pressed.bind(btn))
			btn.focus_mode = Control.FOCUS_NONE
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn.tooltip_text = btn.name
			var keymap = toolbar_keymaps.get(btn.name)
			if keymap:
				btn.shortcut = Shortcut.new()
				var event:InputEventAction = InputEventAction.new()
				event.action = keymap['action']
				btn.shortcut.events.append(event)
				var action = g.keyChain.add_action(keymap['action'], 
												   btn.name, 
												   name)
				if keymap.get('event'):
					action.bind_event(keymap['event'])


func _on_button_pressed(btn):
	var btn_name :String = btn.name
	if btn is ToolBtnGroup:
		btn_name = btn.current_name
		if current_tool_name == btn_name:
			btn.next_btn()
			btn_name = btn.current_name
	current_tool_name = btn_name
	activated.emit(TOOL_ID_MAP.get(current_tool_name, -1))
	# tool buttons must switch `Action Mode` to `Button Press`
	# to prevent mouse up outside switch to pressed style but not really pressed.
	
