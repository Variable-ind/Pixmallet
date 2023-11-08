class_name GradientEditNode extends PanelContainer

signal updated(gradient, cc)

var current_cursor = null
var continuous_change := true
# showing a color picker popup to change a cursor's color

@onready var x_offset: float:
	get: return size.x

@onready var texture_rect := $TextureRect
@onready var texture :GradientTexture2D = texture_rect.texture
@onready var gradient :Gradient = texture.gradient
@onready var color_picker_popup := $PopupPanel
@onready var color_picker := $PopupPanel/ColorPicker


func _ready():
	color_picker.color_changed.connect(_on_color_changed)
	resized.connect(_on_resized)
	

func load_gradient_colors(colors:PackedColorArray):
	current_cursor = null
	color_picker_popup.hide()
	gradient.offsets = []
	for i in colors.size():
		if not colors[i] is Color:
			continue
		var color :Color = colors[i]
		var point = i * (1.0 / (colors.size() - 1))
		gradient.add_point(point, color)
	place_cursors()


func place_cursors():
	for cur in texture_rect.get_children():
		if cur is GradientCursor:
			texture_rect.remove_child(cur)
			cur.queue_free()
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


func update_from_value():
	gradient.offsets = []
	for c in texture_rect.get_children():
		if c is GradientCursor:
			var point: float = c.position.x / x_offset
			point = clampf(point, 0.0, size.x)
			gradient.add_point(point, c.color)
	updated.emit(gradient, continuous_change)
	continuous_change = true


func add_cursor(x: float, color: Color):
	var cursor := GradientCursor.new()
	texture_rect.add_child(cursor)
	cursor.movable_range = size.x
	cursor.position.x = x - cursor.WIDTH / 2.0
	cursor.color = color
	cursor.double_clicked.connect(_on_cursor_double_clicked)
	cursor.pressed.connect(_on_cursor_pressed)
	cursor.removed.connect(_on_cursor_removed)


func get_gradient_color(x: float) -> Color:
	return gradient.sample(x / x_offset)


func _on_cursor_double_clicked(cursor):
	current_cursor = cursor
	color_picker_popup.show()


func _on_cursor_pressed(cursor, btn_pressed):
	current_cursor = cursor
	if not btn_pressed:
		update_from_value()


func _on_color_changed(color: Color):
	if current_cursor:
		current_cursor.color = color
		update_from_value()


func _on_cursor_removed(cursor :GradientCursor):
	for conn in cursor.removed.get_connections():
		cursor.removed.disconnect(conn['callable'])
	for conn in cursor.pressed.get_connections():
		cursor.pressed.disconnect(conn['callable'])
	for conn in cursor.double_clicked.get_connections():
		cursor.double_clicked.disconnect(conn['callable'])
	if current_cursor == cursor:
		current_cursor = null
	continuous_change = false
	update_from_value()


func _on_resized() :
	if not gradient:
		return
	place_cursors()


func set_interpolation_mode(index: Gradient.InterpolationMode):
	gradient.interpolation_mode = index


class GradientCursor extends Control:
	signal double_clicked(gcursor)
	signal pressed(gcursor)
	signal removed(gcursor)

	const WIDTH := 10
	const HEIGHT := 15
	
	var color :Color :
		set(val):
			color = val
			queue_redraw()
	var movable_range := 0.0
	var is_pressed := false

	func _ready():
		position = Vector2(0, HEIGHT)
		size = Vector2(WIDTH, HEIGHT)
	
	func _draw():
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
			draw_polyline(polygon, Color.BLACK)
		else:
			draw_polyline(polygon, Color.WHITE)

	func _gui_input(ev: InputEvent):
		if ev is InputEventMouseButton:
			if ev.button_index == MOUSE_BUTTON_LEFT:
				is_pressed = ev.pressed
				pressed.emit(self, is_pressed)
				if ev.double_click:
					double_clicked.emit(self)
					is_pressed = false
			elif ev.button_index == MOUSE_BUTTON_RIGHT:
				remove()
		elif ev is InputEventMouseMotion and is_pressed:
			position.x += get_local_mouse_position().x
			position.x = clampf(position.x, 0, movable_range)
			position.x -= WIDTH / 2.0
			
		
	func remove():
		removed.emit(self)
		queue_free()
