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

@onready var toolbtns = $ToolBtns


func _ready():
	for btn in toolbtns.get_children():
		if btn is Button:
			btn.pressed.connect(_on_button_pressed.bind(btn))


func _on_button_pressed(btn):
	active_tool.emit(TOOL_ID_MAP.get(btn.name, -1))
