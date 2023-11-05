class_name GradientEditNode extends Control

signal updated(gradient, cc)

var continuous_change := true
var active_cursor: GradientCursor  
# showing a color picker popup to change a cursor's color

@onready var x_offset: float = size.x - GradientCursor.WIDTH
@onready var texture_rect := $TextureRect
@onready var texture :GradientTexture2D = texture_rect.texture
@onready var gradient := texture.gradient

@onready var color_picker_popup := $ColorPickerPopup
@onready var color_picker := $ColorPickerPopup/ColorPicker


func _ready():
	place_cursors()


func place_cursors():
	for cur in texture_rect.get_children():
		if cur is GradientCursor:
			texture_rect.remove_child(cur)
			cur.remove()
	for i in gradient.get_point_count():
		var p: float = gradient.get_offset(i)
		add_cursor(p * x_offset, gradient.get_color(i))


func _gui_input(ev: InputEvent):
	if ev is InputEventMouseButton:
		if ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			var p := clampf(ev.position.x, 0, x_offset)
			add_cursor(p, get_gradient_color(p))
			continuous_change = false
			update_from_value()


func update_from_value() -> void:
	gradient.offsets = []
	for c in texture_rect.get_children():
		if c is GradientCursor:
			var point: float = c.position.x / x_offset
			gradient.add_point(point, c.color)
	updated.emit(gradient, continuous_change)
	continuous_change = true


func add_cursor(x: float, color: Color):
	var cursor := GradientCursor.new()
	texture_rect.add_child(cursor)
	cursor.position.x = x
	cursor.color = color


func select_cursor(cursor: GradientCursor, pos: Vector2):
	active_cursor = cursor
	color_picker.color = cursor.color
	if pos.x > global_position.x + (size.x / 2.0):
		pos.x = global_position.x + size.x
	else:
		pos.x = global_position.x - $Popup.size.x
	color_picker_popup.position = pos
	color_picker_popup.popup()


func get_gradient_color(x: float) -> Color:
	return gradient.sample(x / x_offset)


func _on_color_changed(color: Color) -> void:
	active_cursor.color = color


func _on_resized() -> void:
	if not gradient:
		return
	x_offset = size.x - GradientCursor.WIDTH
	place_cursors()


func set_interpolation_mode(index: Gradient.InterpolationMode):
	gradient.interpolation_mode = index


class GradientCursor extends Control:
	
	signal selected(gcursor)
	signal removed(gcursor)
	signal pressed(gcursor)
	signal released(gcursor)

	const WIDTH := 10
	
	var color: Color
	var is_sliding := false

	func _ready() -> void:
		position = Vector2(0, 15)
		size = Vector2(WIDTH, 15)

	func _draw() -> void:
		var polygon := PackedVector2Array(
			[
				Vector2(0, 5),
				Vector2(WIDTH / 2.0, 0),
				Vector2(WIDTH, 5),
				Vector2(WIDTH, 15),
				Vector2(0, 15),
				Vector2(0, 5)
			]
		)
		var c := color
		c.a = 1.0
		draw_colored_polygon(polygon, c)
		if color.v > 0.5:
			draw_polyline(polygon, Color(0.0, 0.0, 0.0))
		else:
			draw_polyline(polygon, Color(1.0, 1.0, 1.0))

	func _gui_input(ev: InputEvent):
		if ev is InputEventMouseButton:
			if ev.button_index == MOUSE_BUTTON_LEFT:
				if ev.double_click:
					selected.emit(self)
				elif ev.pressed:
					pressed.emit(self)
					is_sliding = true
				else:
					released.emit(self)
					is_sliding = false
			elif ev.button_index == MOUSE_BUTTON_RIGHT:
				removed.emit(self)
				remove()

	func remove():
		queue_free()

	func _can_drop_data(_position, data):
		return data is Color

	func _drop_data(_position, data):
		color = data
