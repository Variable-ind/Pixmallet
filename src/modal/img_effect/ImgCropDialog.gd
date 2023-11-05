class_name ImgCropDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project
var crop_rect := Rect2i()

@export var preview_bgcolor := Color(1, 1, 1, 0.2)

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var preview := %Preview


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.bgcolor = preview_bgcolor
	preview.resized.connect(_on_resized)
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)


func launch(proj:Project):
	preview_image.fill(Color.TRANSPARENT)
	project = proj
	crop_rect = Rect2i()
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
	crop_rect = preview_image.get_used_rect()
	if crop_rect.has_area():
		var cropped_img = Image.create(crop_rect.size.x, 
									   crop_rect.size.y,
									   false,
									   preview_image.get_format())
		cropped_img.blit_rect(preview_image, crop_rect, Vector2i.ZERO)
		preview_image.copy_from(cropped_img)
		preview.render(preview_image)
		confirm_btn.disabled = false
	else:
		preview.render(preview_image)
		confirm_btn.disabled = true


func _on_confirmed():
	project.crop_to(crop_rect)
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)	
