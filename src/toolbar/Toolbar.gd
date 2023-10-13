class_name Toolbar extends ScrollContainer

signal active_tool(toolId)

enum {
	SEL_RECT,
	SEL_ELLIPSE,
	SEL_POLYGON,
	SEL_COLOR,
	SEL_MAGIC,
	SEL_LASSO,
	SHAPE_LINE,
	SHAPE_RECT,
	SHAPE_ELLIPSE,
	PENCIL,
	ERASER,
	FILL,
	PAN,
	MOVE,
	COLOR_PICKER,
	CROP,
	ZOOM,
	SHADING,
}

const TOOL_ID_MAP: Dictionary = {
	'SelRect': SEL_RECT,
	'SelEllipse': SEL_ELLIPSE,
	'SelPolygon': SEL_POLYGON,
	'SelColor': SEL_COLOR,
	'SelMagic': SEL_MAGIC,
	'SelLasso': SEL_LASSO,
	'ShapeLine': SHAPE_LINE,
	'ShapeRect': SHAPE_RECT,
	'ShapeEllipse': SHAPE_ELLIPSE,
	'Pencil': PENCIL,
	'Eraser': ERASER,
	'Fill': FILL,
	'Pan': PAN,
	'Move': MOVE,
	'ColorPicker': COLOR_PICKER,
	'Crop': CROP,
	'Zoom': ZOOM,
	'Shading': SHADING,
}

@onready var toolbtns = $ToolBtns
@onready var toolbar_keymaps = {
	'Select': {'action': 'select', 'event': KeyChain.makeEventKey(KEY_W)},
	'Shape': {'action': 'shape', 'event': KeyChain.makeEventKey(KEY_A)},
	'Pencil': {'action': 'pencil', 'event': KeyChain.makeEventKey(KEY_B)},
	'Eraser': {'action': 'eraser', 'event': KeyChain.makeEventKey(KEY_E)},
	'Fill': {'action': 'fill', 'event': KeyChain.makeEventKey(KEY_G)},
	'Pan': {'action': 'pan', 'event': KeyChain.makeEventKey(KEY_SPACE)},
	'Move': {'action': 'move', 'event': KeyChain.makeEventKey(KEY_V)},
	'ColorPicker': {'action': 'color_picker', 
					'event': KeyChain.makeEventKey(KEY_I)},
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
	var btn_name :String = btn.sel_name if btn is ExtendableButton else btn.name
	active_tool.emit(TOOL_ID_MAP.get(btn_name, -1))

	# toogle mode button must switch `Action Mode` to `Button Press`
	# to prevent mouse up outside switch to pressed style but not really pressed.
	
