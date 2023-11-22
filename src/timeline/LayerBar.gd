class_name LayerBar extends Panel

enum Type {
	BASE,
	PIXEL,
	GROUP
}

var type := Type.BASE

var layer: BaseLayer
var layer_name_backup := ''

var selected := false:
	set(val):
		selected = val
		queue_redraw()

var index :int :
	get: 
		if layer:
			return layer.index
		else:
			return -1

var is_visible := true
var is_locked := false
var is_linked := false
var is_current := false

@export var selected_color := Color.DEEP_SKY_BLUE
@export var selected_line_width := 2

@onready var layer_name: LineEdit = $row/LayerName
@onready var btn_link: Button = $row/BtnLink
@onready var btn_visible: Button = $row/BtnVisible
@onready var btn_lock: Button = $row/BtnLock


func _ready():
	# layer_name:
	layer_name.editable = false
	layer_name.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	layer_name.text_submitted.connect(_on_layer_name_submitted)
	
	layer_name.gui_input.connect(_on_layer_name_gui_input)
	layer_name.focus_entered.connect(_on_layer_name_focused)
	layer_name.focus_exited.connect(_on_layer_name_unfocused)

	# buttons
	btn_link.toggled.connect(_on_link_toggled)
	btn_visible.toggled.connect(_on_visible_toggled)
	btn_lock.toggled.connect(_on_lock_toggled)


func destroy():
	layer_name.gui_input.disconnect(_on_layer_name_gui_input)
	layer_name.focus_entered.disconnect(_on_layer_name_focused)
	layer_name.focus_exited.disconnect(_on_layer_name_unfocused)
	
	layer_name.text_submitted.disconnect(_on_layer_name_submitted)
	
	# buttons
	btn_link.toggled.disconnect(_on_link_toggled)
	btn_visible.toggled.disconnect(_on_visible_toggled)
	btn_lock.toggled.disconnect(_on_lock_toggled)
	
	queue_free()
	

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


func _on_layer_name_submitted(new_text:String):
	if not new_text:
		layer_name.text = layer_name_backup
	layer.name = layer_name.text
	layer_name.release_focus()


func _on_layer_name_focused():
	layer_name.mouse_default_cursor_shape = Control.CURSOR_IBEAM


func _on_layer_name_unfocused():
	layer_name.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	

func _on_layer_name_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if is_current:
			layer_name_backup = layer_name.text
			layer_name.editable = true
		if event.ctrl_pressed:
			selected = true
		else:
			selected = true
			is_current = true


func _draw():
	if selected:
		var rect := Rect2i(Vector2i.ZERO, size)
		rect = rect.grow_side(Side.SIDE_LEFT, -1)
		if is_current:
			selected_color.a = 1.0
		else:
			selected_color.a = 0.6
		draw_rect(rect, selected_color, false, selected_line_width)


func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var loc_evt := make_input_local(event)
		if not has_point(loc_evt.position) and layer_name.has_focus():
			layer_name.text_submitted.emit(layer_name.text)
	elif event is InputEventKey and Input.is_key_pressed(KEY_ESCAPE):
		layer_name.text = layer_name_backup
		layer_name.editable = false

