class_name AdjustmentTool extends HBoxContainer

signal adjusted(adjustId)



enum {
	FLIP_X,
	FLIP_Y,
	ROTATE_CCW,
	ROTATE_CW,
#	MIRROR_H,
#	MIRROR_V,
#	PREFECT_PX,
}

const ADJUST_ID_MAP :Dictionary = {
	'FlipX': FLIP_X,
	'FlipY': FLIP_Y,
	'RotateCCW': ROTATE_CCW,
	'RotateCW': ROTATE_CW,
#	'MirrorH': MIRROR_H,
#	'MirrorV': MIRROR_V,
#	'PerfectPX': PREFECT_PX,
}


func _ready():
	for	btn in get_children():
		if btn is Button:
			btn.pressed.connect(_on_pressed.bind(btn))


func _on_pressed(btn):
	adjusted.emit(ADJUST_ID_MAP.get(btn.name, -1))
