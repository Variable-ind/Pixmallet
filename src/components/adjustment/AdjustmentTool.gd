extends HBoxContainer

class_name AdjustmentTool

signal active_adjust_tool(adjustId)


enum {
	FLIP_H,
	FLIP_V,
	ROTATE_CCW,
	ROTATE_CW,
	MIRROR_H,
	MIRROR_V,
	PREFECT_PX,
}

const ADJUST_ID_MAP :Dictionary = {
	'FlipH': FLIP_H,
	'FlipV': FLIP_V,
	'RotateCCW': ROTATE_CCW,
	'RotateCW': ROTATE_CW,
	'MirrorH': MIRROR_H,
	'MirrorV': MIRROR_V,
	'PerfectPX': PREFECT_PX,
}


func _ready():
	for	btn in get_children():
		if btn is Button:
			btn.pressed.connect(_on_pressed.bind(btn))
			btn.mouse_entered.connect(_on_mouseover.bind(btn))
			btn.mouse_exited.connect(_on_mouseout.bind(btn))
			btn.self_modulate = Color.WEB_GRAY


func _on_pressed(btn):
	active_adjust_tool.emit(ADJUST_ID_MAP.get(btn.name, -1))
	
	
func _on_mouseover(btn):
	btn.self_modulate = Color.WHITE
	
	
func _on_mouseout(btn):
	if btn.toggle_mode and btn.button_pressed:
		btn.self_modulate = Color.WHITE
	else:
		btn.self_modulate = Color.WEB_GRAY
