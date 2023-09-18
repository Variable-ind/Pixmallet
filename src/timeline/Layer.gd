extends Panel

class_name Layer

enum LayerState {
	VISIBLE,
	LOCK,
	LINK,
}

var layer_name_overlayer : ColorRect = ColorRect.new()

@onready var layer_name: LineEdit = $row/LayerName

func _ready():
	
	layer_name_overlayer.color = Color.TRANSPARENT
	layer_name_overlayer.size = layer_name.size
	layer_name_overlayer.gui_input.connect(_on_layer_name_editing)
	layer_name_overlayer.mouse_exited.connect(_on_layer_name_release)
	
	layer_name.editable = false
	layer_name.add_child(layer_name_overlayer)
	layer_name.focus_exited.connect(_on_layer_name_release)
	layer_name.resized.connect(_on_resized)


func _on_layer_name_editing(event):
	if event is InputEventMouseButton and event.pressed:
		layer_name_overlayer.hide()
		layer_name.editable = true


func _on_layer_name_release():
	layer_name.editable = false
	layer_name_overlayer.show()


func _on_resized():
	layer_name_overlayer.size = layer_name.size
