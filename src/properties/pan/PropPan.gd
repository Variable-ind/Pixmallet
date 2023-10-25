class_name PropPan extends VBoxContainer

var camera :Variant


func subscribe(new_camera:Camera2D):
	unsubscribe()
	camera = new_camera


func unsubscribe():
	camera = null

