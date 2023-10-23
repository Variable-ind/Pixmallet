class_name PropZoom extends VBoxContainer

var camera :Variant

@onready var btn_fit := $BtnFit
@onready var btn_100 := $Btn100


func subscribe(new_camera:Camera2D):
	unsubscribe()
	camera = new_camera

	btn_fit.pressed.connect(_on_fit_to_frame)
	btn_100.pressed.connect(_on_zoom_100)


func unsubscribe():
	if btn_fit.pressed.is_connected(_on_fit_to_frame):
		btn_fit.pressed.disconnect(_on_fit_to_frame)
	if btn_100.pressed.is_connected(_on_zoom_100):
		btn_100.pressed.disconnect(_on_zoom_100)
	camera = null


func _on_fit_to_frame():
	camera.fit_to_frame()
	

func _on_zoom_100():
	camera.zoom_100()
