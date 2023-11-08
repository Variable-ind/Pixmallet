class_name GradientEditNode extends PanelContainer

signal updated(gradient, cc)

var continuous_change := true
# showing a color picker popup to change a cursor's color

@onready var x_offset: float:
	get: return size.x - GradientCursor.WIDTH

@onready var texture_rect := $TextureRect
@onready var texture :GradientTexture2D = texture_rect.texture
@onready var gradient := texture.gradient


func load_gradient(colors:Array):
	gradient.offsets = []
	for i in colors.size():
		if not colors[i] is Color:
			continue
		var color :Color = colors[i]
		gradient.add_point(1.0, color)
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


func update_from_value():
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
	cursor.movable_range = size.x
	cursor.position.x = x
	cursor.color = color
	cursor.color_changed.connect(_on_cursor_color_changed)
	cursor.removed.connect(_on_cursor_removed)


func get_gradient_color(x: float) -> Color:
	return gradient.sample(x / x_offset)


func _on_cursor_color_changed(_color: Color):
	update_from_value()


func _on_cursor_removed(cursor :GradientCursor):
	cursor.remove()
	continuous_change = false
	update_from_value()


func _on_resized() -> void:
	if not gradient:
		return
	place_cursors()


func set_interpolation_mode(index: Gradient.InterpolationMode):
	gradient.interpolation_mode = index


class GradientCursor extends ColorPickerButton:
	
	signal removed(gcursor)

	const WIDTH := 10
	const HEIGHT := 15
	
	var movable_range := 0.0
	var is_pressed := false

	func _ready():
		position = Vector2(0, HEIGHT)
		size = Vector2(WIDTH, HEIGHT)
		flat = true
		var picker = get_picker()
		picker.can_add_swatches = false
#		picker.color_modes_visible = false
		picker.color_mode = ColorPicker.MODE_RGB
#		color_picker.deferred_mode = true
		picker.sampler_visible = false
		picker.presets_visible = false
#		picker.picker_shape = ColorPicker.SHAPE_NONE
		picker.hex_visible = true
		theme_type_variation = 'TextureBtn'
	
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
				is_pressed = true
			elif ev.button_index == MOUSE_BUTTON_RIGHT:
				removed.emit(self)
		elif ev is InputEventMouseMotion and is_pressed:
			position.x += get_local_mouse_position().x
			position.x = min(max(0, position.x), movable_range - size.x)

	func remove():
		for conn in removed.get_connections():
			conn['callable'].disconnect()
		queue_free()
