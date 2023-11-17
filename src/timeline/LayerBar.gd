class_name LayerBar extends Panel

enum Type {
	BASE,
	PIXEL,
	GROUP
}

var type := Type.PIXEL:
	set = set_type

var project_layer: BaseLayer
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
	layer_name.gui_input.connect(_on_layer_name_input)
	layer_name.text_submitted.connect(_on_layer_name_submitted)
	
	# buttons
	btn_link.toggled.connect(_on_link_toggled)
	btn_visible.toggled.connect(_on_visible_toggled)
	btn_lock.toggled.connect(_on_lock_toggled)


func set_type(new_type:Type):
	if type == new_type:
		return
	type = new_type
	btn_visible.visible = type != Type.GROUP


func attach(layer:BaseLayer):
	if layer is PixelLayer:
		type = Type.PIXEL
	elif layer is GroupLayer:
		type = Type.GROUP
	else:
		type = Type.BASE


func _on_link_toggled(btn_pressed:bool):
	if type == Type.PIXEL:
		print(btn_pressed)
	

func _on_visible_toggled(btn_pressed:bool):
	print(btn_pressed)


func _on_lock_toggled(btn_pressed:bool):
	print(btn_pressed)


func _on_layer_name_editing(event):
	if event is InputEventMouseButton and event.pressed:
		layer_name_overlayer.hide()
		layer_name.editable = true


func _on_layer_name_input(event):
	if event is InputEventMouseButton and event.pressed:
		print('fuck')
	elif event is InputEventKey and Input.is_key_pressed(KEY_ESCAPE):
		layer_name.text = layer_name_backup
		layer_name.editable = false
		layer_name_overlayer.show()


func _on_layer_name_focused():
	layer_name_backup = layer_name.text


func _on_layer_name_release():
	layer_name.editable = false
	layer_name_overlayer.show()


func _on_layer_name_submitted(new_text:String):
	print(new_text)
	layer_name.release_focus()


func _on_resized():
	layer_name_overlayer.size = layer_name.size


