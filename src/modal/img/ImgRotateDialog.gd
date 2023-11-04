class_name ImgRotateDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
var src_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var rotated:= 0


@export var frame_line_color := Color.DIM_GRAY

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var preview := %Preview

@onready var btn_rotate_cw := %BtnRotateCW
@onready var btn_rotate_ccw := %BtnRotateCCW


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.frame_line_color = frame_line_color
	preview.resized.connect(_on_resized)
	
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
	rotated = 0
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
	src_image.copy_from(preview_image)
	preview.render(preview_image)
	btn_rotate_cw.disabled = preview_image.is_invisible()
	btn_rotate_ccw.disabled = preview_image.is_invisible()
	confirm_btn.disabled = preview_image.is_invisible()


func _on_rotate_cw():
	rotated = (rotated + 90) % 360
	rotate_90(CLOCKWISE)


func _on_rotate_ccw():
	rotated = (rotated - 90) % 360
	rotate_90(COUNTERCLOCKWISE)
	

func rotate_90(direction:ClockDirection):
	var w: = src_image.get_width()
	var h: = src_image.get_height()
	var cropped_img := Image.create(w, h, false, src_image.get_format())
	
	preview_image.rotate_90(direction)
	var rotate_rect := Rect2i(Vector2i.ZERO, preview_image.get_size())
	var dst = Vector2i(
		floor((w - rotate_rect.size.x) * 0.5),
		floor((h - rotate_rect.size.y) * 0.5)
	)
	cropped_img.blit_rect(preview_image, rotate_rect, dst)
	preview.render(cropped_img)


func _on_confirmed():
	var direction
	
	if rotated == 0:
		return
	elif rotated > 0:
		direction = CLOCKWISE
	else:
		direction = COUNTERCLOCKWISE

	var abs_rotated = abs(rotated)
	
	for cel in project.selected_cels:
		var img := cel.get_image()
		if abs_rotated >= 180: # 180 or 270
			img.rotate_180()
			abs_rotated -= 180
		
		# rotated the rest 90 after rotated 180 if not 0.
		# no other possibility in this case.
		if abs_rotated > 0: # 90 or 270
			var w: = img.get_width()
			var h: = img.get_height()
			var rotate_img := img.duplicate()
			rotate_img.rotate_90(direction)
			
			var rotate_rect := Rect2i(Vector2i.ZERO, rotate_img.get_size())
			var dst = Vector2i(
				floor((w - rotate_rect.size.x) * 0.5),
				floor((h - rotate_rect.size.y) * 0.5)
			)
			img.fill(Color.TRANSPARENT)
			img.blit_rect(rotate_img, rotate_rect, dst)
			
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
