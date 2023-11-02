class_name ImgRotateDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var rotate:= 0


@export var frame_line_color := Color.DIM_GRAY

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var preview := %Preview

@onready var btn_rotate_cw := %BtnRotateCW
@onready var btn_rotate_ccw := %BtnRotateCCW


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.frame_line_color = frame_line_color
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	btn_rotate_cw.pressed.connect(_on_rotate_cw)
	btn_rotate_ccw.pressed.connect(_on_rotate_ccw)
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)


func launch(proj:Project):
	preview_image.fill(Color.TRANSPARENT)
	project = proj
	cancel_btn.grab_focus.call_deferred()
	update_preview()
	visible = true


func update_preview():
	for img in project.current_frame.get_images():
		if preview_image.get_width() != img.get_width() or \
		   preview_image.get_height() != img.get_height():
			preview_image.resize(img.get_width(), img.get_height())
		if img.get_format() != preview_image.get_format():
			preview_image.convert(img.get_format())
		preview_image.blit_rect(img,
								Rect2i(Vector2i.ZERO, img.get_size()), 
								Vector2i.ZERO)

	preview.update_texture(preview_image)


func _on_rotate_cw():
	# Limit between +-360
#	rotate = rotate % 180
#	rotate = (rotate + 360) % 360
	rotate = ((rotate + 90) % 180 + 360)
	print(rotate)
	preview_image.rotate_90(CLOCKWISE)
	preview.update_texture(preview_image)


func _on_rotate_ccw():
	# Limit between +-360
#	rotate = rotate % 180
#	rotate = (rotate + 360) % 360
	rotate = ((rotate - 90) % 180 + 360)
	print(rotate)
	preview_image.rotate_90(COUNTERCLOCKWISE)
	preview.update_texture(preview_image)


func _on_confirmed():
	var direction
	if rotate > 0:
		direction = CLOCKWISE
	else:
		direction = COUNTERCLOCKWISE

	var r_180_times = abs(rotate) / 180
	var r_90_times = abs(rotate) % 180
	for cel in project.selected_cels:
		for th in range(r_180_times):
			cel.get_image().rotate_180()
		for tn in range(r_90_times):
			cel.get_image().rotate_90(direction)
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)
