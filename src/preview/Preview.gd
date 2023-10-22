class_name Preview extends Panel


@onready var preview_canvas := %PreviewCanvas
@onready var preview_camera := %PreviewCamera

@onready var btn_play := %BtnPlay
@onready var btn_play_reverse := %BtnPlayReverse
@onready var btn_zoom_out := %BtnZoomOut
@onready var btn_zoom_in := %BtnZoomInt
@onready var zoom_slider := %ZoomSlider


func _ready():
	btn_play.toggled.connect(_on_play_toggled.bind(true))
	btn_play_reverse.toggled.connect(_on_play_toggled.bind(false))
	btn_zoom_out.pressed.connect(_on_zoom_out)
	btn_zoom_in.pressed.connect(_on_zoom_in)
	zoom_slider.value_changed(_on_zoom_slid)
	

func load_project(proj):
	preview_canvas.attach_project(proj)
	preview_camera.canvas_size = proj.size


func _on_play_toggled(btn_pressed, forward):
	if btn_pressed:
		if forward:
			print('play')
		else:
			print('play reverse')
	else:
		print('stop')


func _on_zoom_out():
	preview_camera.zoom_out()
	

func _on_zoom_in():
	preview_camera.zoom_in()
	

func _on_zoom_slid(value):
	preview_camera.zoom_to(value)
