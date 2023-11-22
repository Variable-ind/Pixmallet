class_name LayerBar extends Panel

enum Type {
	BASE,
	PIXEL,
	GROUP
}

var type := Type.BASE

var layer: BaseLayer
var layer_name_overlayer := ColorRect.new()
var layer_name_backup := ''

var is_visible := true
var is_locked := false
var is_linked := false

@onready var layer_name: LineEdit = $row/LayerName
@onready var btn_link: Button = $row/BtnLink
@onready var btn_visible: Button = $row/BtnVisible
@onready var btn_lock: Button = $row/BtnLock


func _ready():
	# layer_name:
	layer_name_overlayer.color = Color.TRANSPARENT
	layer_name_overlayer.size = layer_name.size
	layer_name_overlayer.gui_input.connect(_on_layer_name_editing)
	layer_name_overlayer.mouse_exited.connect(_on_layer_name_release)
	
	layer_name.editable = false
	layer_name.add_child(layer_name_overlayer)
	layer_name.focus_entered.connect(_on_layer_name_focused)
	layer_name.focus_exited.connect(_on_layer_name_release)
	layer_name.resized.connect(_on_resized)
	layer_name.text_submitted.connect(_on_layer_name_submitted)
	
	# buttons
	btn_link.toggled.connect(_on_link_toggled)
	btn_visible.toggled.connect(_on_visible_toggled)
	btn_lock.toggled.connect(_on_lock_toggled)


func attach(proj_layer:BaseLayer):
	layer = proj_layer
	if layer is PixelLayer:
		type = Type.PIXEL
	elif layer is GroupLayer:
		type = Type.GROUP
	else:
		type = Type.BASE
	
	layer_name.text = layer.name
	btn_link.visible = type == Type.PIXEL
	btn_link.set_pressed_without_signal(layer.is_linked)
	btn_visible.set_pressed_without_signal(layer.is_visible)
	btn_lock.set_pressed_without_signal(layer.is_locked)
	visible = true


func toggle_layer_name(is_focused:bool):
	if is_focused:
		layer_name.editable = true
		layer_name_overlayer.hide()
	else:
		layer_name.editable = false
		layer_name_overlayer.show()


func has_point(point):
	return Rect2i(Vector2i.ZERO, size).has_point(point)


func _on_link_toggled(btn_pressed:bool):
	if type == Type.PIXEL:
		layer.is_linked = btn_pressed
		if not btn_pressed:
			layer.cel_link_sets.clear()
	

func _on_visible_toggled(btn_pressed:bool):
	layer.is_visible = btn_pressed


func _on_lock_toggled(btn_pressed:bool):
	layer.is_locked = btn_pressed


func _on_layer_name_editing(event):
	if event is InputEventMouseButton and event.pressed:
		toggle_layer_name(true)


func _on_layer_name_focused():
	layer_name_backup = layer_name.text


func _on_layer_name_release():
	layer.name = layer_name.text
	toggle_layer_name(false)


func _on_layer_name_submitted(new_text:String):
	if not new_text:
		layer_name.text = layer_name_backup
	layer.name = layer_name.text
	layer_name.release_focus()


func _on_resized():
	layer_name_overlayer.size = layer_name.size


func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var loc_evt := make_input_local(event)
		if not has_point(loc_evt.position) and layer_name.has_focus():
			layer_name.text_submitted.emit(layer_name.text)
	elif event is InputEventKey and Input.is_key_pressed(KEY_ESCAPE):
		layer_name.text = layer_name_backup
		layer_name.release_focus()

