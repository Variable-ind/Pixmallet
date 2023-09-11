extends ScrollContainer

class_name Toolbar

signal active_tool(toolId)

enum {
	SEL_RECT,
	SEL_ELLIPSE,
	SEL_POLYGON,
	SEL_COLOR,
	SEL_MAGIC,
	SEL_LASSO,
	LINE,
	RECT,
	ELLIPSE,
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
	'Sel_Lass': SEL_LASSO,
	'Line': LINE,
	'Rect': RECT,
	'Ellipse': ELLIPSE,
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


func _ready():
	for btn in get_children():
		if btn is Button:
			btn.pressed.connect(_on_button_pressed.bind(btn))


func _on_button_pressed(btn):
	var btn_name :String = btn.sel_name if btn is ExtendableButton else btn.name
	active_tool.emit(TOOL_ID_MAP.get(btn_name, -1))
	# toogle mode button must switch `Action Mode` to `Button Press`
	# to prevent mouse up outside switch to pressed style but not really pressed.
	
