class_name Preview extends Panel


@onready var preview_canvas := %PreviewCanvas
@onready var preview_camera := %PreviewCamera
@onready var preview_trans_checker := %PreviewTransChecker

@onready var btn_play := %BtnPlay
@onready var btn_play_reverse := %BtnPlayReverse
@onready var btn_zoom_out := %BtnZoomOut
@onready var btn_zoom_in := %BtnZoomIn
@onready var zoom_slider := %ZoomSlider


func _ready():
	btn_play.toggled.connect(_on_play_toggled)
	btn_play_reverse.toggled.connect(_on_play_reverse_toggled)
	btn_zoom_out.pressed.connect(_on_zoom_out)
	btn_zoom_in.pressed.connect(_on_zoom_in)
	zoom_slider.value_changed.connect(_on_zoom_slid)
	

func load_project(proj):
	preview_canvas.attach_project(proj)
	preview_camera.canvas_size = proj.size
	preview_trans_checker.update_bounds(proj.size)


func _on_play_toggled(btn_pressed):
	if btn_pressed:
		btn_play_reverse.button_pressed = false
		print('play')
	else:
		print('stop')


func _on_play_reverse_toggled(btn_pressed):
	if btn_pressed:
		btn_play.button_pressed = false
		print('play reverse')
	else:
		print('stop')


func _on_zoom_out():
	preview_camera.zoom_out()
	zoom_slider.value = preview_camera.zoom_level
	

func _on_zoom_in():
	preview_camera.zoom_in()
	zoom_slider.value = preview_camera.zoom_level
	

func _on_zoom_slid(value):
	print(value)
	preview_camera.zoom_to(value)
