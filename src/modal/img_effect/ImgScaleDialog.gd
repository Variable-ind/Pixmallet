class_name ImgScaleDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
var scale_size := Vector2i.ZERO

var project :Project

@export var preview_bgcolor := Color(1, 1, 1, 0.2)

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var preview := %Preview

@onready var input_w := %Width
@onready var input_h := %Height


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
	
	input_w.value_changed.connect(_on_width_changed)
	input_h.value_changed.connect(_on_height_changed)


func launch(proj:Project):
	preview_image.fill(Color.TRANSPARENT)
	project = proj
	
	cancel_btn.grab_focus.call_deferred()
	scale_size = project.size.clamp(Vector2i.ONE, project.size)
	input_w.set_value_no_signal(scale_size.x)
	input_h.set_value_no_signal(scale_size.y)
	update_preview()
	visible = true


func update_preview():
	for cel in project.selected_cels:
		var img = cel.get_image()
		if preview_image.get_width() != img.get_width() or \
		   preview_image.get_height() != img.get_height():
			preview_image.resize(img.get_width(), img.get_height())
		if img.get_format() != preview_image.get_format():
			preview_image.convert(img.get_format())
		preview_image.blit_rect(img,
								Rect2i(Vector2i.ZERO, img.get_size()), 
								Vector2i.ZERO)

	preview.render(preview_image)
	confirm_btn.disabled = preview_image.is_invisible()


func scale_image(img:Image):
	var rect := Rect2i(Vector2i.ZERO, img.get_size())
	var tmp_img := img.duplicate()
	tmp_img.resize(scale_size.x, scale_size.y)
	rect.position.x = floor((scale_size.x - rect.size.x) / 2.0)
	rect.position.y = floor((scale_size.y - rect.size.y) / 2.0)
	img.fill(Color.TRANSPARENT)
	img.blit_rect(tmp_img, rect, Vector2i.ZERO)


func _on_width_changed(val :int):
	scale_size.x = val
	scale_image(preview_image)
	preview.render(preview_image)


func _on_height_changed(val :int):
	scale_size.y = val
	scale_image(preview_image)
	preview.render(preview_image)


func _on_confirmed():
	if scale_size != Vector2i.ZERO and scale_size != project.size:
		for cel in project.selected_cels:
			scale_image(cel.get_image())
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
