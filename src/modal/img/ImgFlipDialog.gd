class_name ImgFlipDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var flipped_x:= false
var flipped_y:= false

@export var frame_line_color := Color.DIM_GRAY

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var preview := %Preview
@onready var btn_flip_x := %BtnFlipX
@onready var btn_flip_y := %BtnFlipY


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.frame_line_color = frame_line_color
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	btn_flip_x.pressed.connect(_on_flip_x)
	btn_flip_y.pressed.connect(_on_flip_y)
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
	btn_flip_x.disabled = preview_image.is_invisible()
	btn_flip_y.disabled = preview_image.is_invisible()
	confirm_btn.disabled = preview_image.is_invisible()


func _on_flip_x():
	flipped_x = not flipped_x
	preview_image.flip_x()
	preview.update_texture(preview_image)


func _on_flip_y():
	flipped_y = not flipped_y
	preview_image.flip_y()
	preview.update_texture(preview_image)


func _on_confirmed():
	for cel in project.selected_cels:
		if flipped_x:
			cel.get_image().flip_x()
		if flipped_y:
			cel.get_image().flip_y()
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)
