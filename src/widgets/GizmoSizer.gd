class_name GizmoSizer extends Node2D

signal gizmo_hover_updated(gizmo, status)
signal gizmo_press_updated(gizmo, status)

signal attached
signal activated
signal deactivated

signal updated(rect, rel_pos, status)
signal cursor_changed(cursor)

enum GSPivot {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	MIDDLE_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_CENTER,
	BOTTOM_LEFT,
	MIDDLE_LEFT,
	CENTER,
}

@export var gizmo_color := Color.BLUE:
	set(val):
		gizmo_color = val
		for gizmo in gizmos:
			gizmo.color = gizmo_color
		queue_redraw()
			
@export var gizmo_bgcolor := Color.BLUE:
	set(val):
		gizmo_bgcolor = val
		for gizmo in gizmos:
			gizmo.bgcolor = gizmo_bgcolor
		queue_redraw()

@export var gizmo_size := Vector2(10, 10) :
	set(val):
		gizmo_size = val
		for gizmo in gizmos:
			gizmo.default_size = gizmo_size
		
@export var line_color := Color.BLUE:
	set(val):
		line_color = val
		queue_redraw()

var zoom_ratio := 1.0 :
	set(val):
		zoom_ratio = val
		for gizmo in gizmos:
			gizmo.zoom_ratio = zoom_ratio
		queue_redraw()

var bound_rect := Rect2i(Vector2i.ZERO, Vector2i.ZERO) :
	set(val):
		bound_rect = val
		for gizmo in gizmos:
			set_gizmo_place(gizmo)
		queue_redraw()

var gizmos :Array[Gizmo] = []

var pivot := GSPivot.TOP_LEFT

var pivot_offset :Vector2i :
	get: return get_sizer_pivot_offset(bound_rect.size)
	
var relative_position :Vector2i :  # with pivot, for display on panel
	get: return bound_rect.position + pivot_offset

var pressed_gizmo :Variant = null
var last_position :Variant = null # prevent same with mouse pos from beginning.
var drag_offset := Vector2i.ZERO

var is_dragging := false :
	set(val):
		if is_dragging != val:
			is_dragging = val
			queue_redraw()  # for redraw dragging effect.
	get: return is_dragging

var is_scaling :bool :
	get: return pressed_gizmo != null
	set(val):
		if not val:
			pressed_gizmo = null

var is_activated := false :
	set(val):
		is_activated = val
		for gizmo in gizmos:
			gizmo.visible = is_activated


func _init():
	visible = false


func _ready():
	gizmos.append(Gizmo.new(Gizmo.Type.TOP_LEFT))
	gizmos.append(Gizmo.new(Gizmo.Type.TOP_CENTER))
	gizmos.append(Gizmo.new(Gizmo.Type.TOP_RIGHT))
	gizmos.append(Gizmo.new(Gizmo.Type.MIDDLE_RIGHT))
	gizmos.append(Gizmo.new(Gizmo.Type.BOTTOM_RIGHT))
	gizmos.append(Gizmo.new(Gizmo.Type.BOTTOM_CENTER))
	gizmos.append(Gizmo.new(Gizmo.Type.BOTTOM_LEFT))
	gizmos.append(Gizmo.new(Gizmo.Type.MIDDLE_LEFT))
	for gizmo in gizmos:
		gizmo.color = gizmo_color
		gizmo.bgcolor = gizmo_bgcolor
		gizmo.default_size = gizmo_size
		gizmo.hover_updated.connect(_on_gizmo_hover_updated)
		gizmo.press_updated.connect(_on_gizmo_press_updated)
		add_child(gizmo)


func attach(rect :Rect2i):
	if bound_rect == Rect2i(): # prevent multiple attach place bound rect.
		bound_rect = rect
	attached.emit()
	visible = true


func frozen(frozen_it := true):
	set_process_input(not frozen_it)
	for gizmo in gizmos:
		gizmo.set_process_input(not frozen_it)
	

func reset():
	visible = false
	bound_rect = Rect2i()
	is_activated = false
	drag_offset = Vector2i.ZERO
	last_position = null
	is_dragging = false
	is_scaling = false
	queue_redraw()


func set_pivot(pivot_id):
	pivot = pivot_id
	if is_activated:
		updated.emit(bound_rect, relative_position, is_activated)


func hire():
	if is_activated:
		return
	is_activated = true

	activated.emit()
	updated.emit(bound_rect, relative_position, is_activated)
	queue_redraw()
	

func dismiss():
	if not is_activated:
		return
	
	is_activated = false
	drag_offset = Vector2i.ZERO
	last_position = null
	is_dragging = false
	is_scaling = false
#	pressed_gizmo = null # already set to null in is_scaling setter.

	deactivated.emit()
	updated.emit(bound_rect, relative_position, is_activated)
	queue_redraw()


func drag_to(pos :Vector2i):
	if last_position == pos:
		return
	# use to prevent running while already stop.
	last_position = pos
	
	pos -= drag_offset  # DO calculate drag_offset just pressed, NOT here.

	# convert to local pos from the rect zero pos. 
	# DO NOT use get_local_mouse_position, because bound_rect is not zero pos.
	bound_rect.position = drag_snapping(bound_rect, pos)
	
	for gzm in gizmos:
		set_gizmo_place(gzm)
	
	updated.emit(bound_rect, relative_position, is_activated)


func move_to(to_pos :Vector2i, use_pivot := true):
	var _offset := pivot_offset if use_pivot else Vector2i.ZERO
	bound_rect.position = to_pos - _offset
	updated.emit(bound_rect, relative_position, is_activated)


func move_delta(delta :int, orientation:Orientation):
	var dest_pos := bound_rect.position
	match orientation:
		HORIZONTAL: dest_pos.x += delta
		VERTICAL: dest_pos.y += delta
	
	bound_rect.position = dest_pos
	updated.emit(bound_rect, relative_position, is_activated)


func scale_to(pos :Vector2i):
	pos = scale_snapping(pos)

	if last_position == pos or not pressed_gizmo:
		return
	# use to prevent running while already stop.
	last_position = pos
	
	match pressed_gizmo.type:
		# size > (1, 1) already limited by not allowed drag to same point.
		Gizmo.Type.TOP_LEFT: 
			if pos.x < bound_rect.end.x and pos.y < bound_rect.end.y:
				bound_rect.size = bound_rect.end - pos
				bound_rect.position = pos
		Gizmo.Type.TOP_CENTER: 
			if pos.y < bound_rect.end.y:
				bound_rect.size.y = bound_rect.end.y - pos.y
				bound_rect.position.y = pos.y
		Gizmo.Type.TOP_RIGHT: 
			if pos.x > bound_rect.position.x and pos.y < bound_rect.end.y:
				bound_rect.size.x = pos.x - bound_rect.position.x
				bound_rect.size.y = bound_rect.end.y - pos.y
				bound_rect.position.y = pos.y
		Gizmo.Type.MIDDLE_RIGHT:
			if pos.x > bound_rect.position.x:
				bound_rect.size.x = pos.x - bound_rect.position.x
		Gizmo.Type.BOTTOM_RIGHT:
			if pos.x > bound_rect.position.x and pos.y > bound_rect.position.y:
				bound_rect.size = pos - bound_rect.position
		Gizmo.Type.BOTTOM_CENTER:
			if pos.y > bound_rect.position.y:
				bound_rect.size.y = pos.y - bound_rect.position.y
		Gizmo.Type.BOTTOM_LEFT:
			if pos.x < bound_rect.end.x and pos.y > bound_rect.position.y:
				bound_rect.size.y = pos.y - bound_rect.position.y
				bound_rect.size.x = bound_rect.end.x - pos.x
				bound_rect.position.x = pos.x
		Gizmo.Type.MIDDLE_LEFT:
			if pos.x < bound_rect.end.x:
				bound_rect.size.x = bound_rect.end.x - pos.x
				bound_rect.position.x = pos.x
	
	for gzm in gizmos:
		set_gizmo_place(gzm)

	updated.emit(bound_rect, relative_position, is_activated)


func resize_to(to_size:Vector2i):
	if to_size.x < 1:
		to_size.x = 1
	if to_size.y < 1:
		to_size.y = 1
		
	var _offset = get_sizer_pivot_offset(to_size)
	var _pos_offset = get_sizer_position_offset(bound_rect.size, to_size)
	
	bound_rect.position += _pos_offset
	bound_rect.size = to_size
	
	updated.emit(bound_rect, relative_position, is_activated)


func set_gizmo_place(gizmo):
	var gpos = bound_rect.position
	var gsize = bound_rect.size
	
	match gizmo.type:
		Gizmo.Type.TOP_LEFT: 
			gizmo.position = Vector2(gpos) + Vector2.ZERO
		Gizmo.Type.TOP_CENTER: 
			gizmo.position = Vector2(gpos) + Vector2(gsize.x / 2, 0)
		Gizmo.Type.TOP_RIGHT: 
			gizmo.position = Vector2(gpos) + Vector2(gsize.x, 0)
		Gizmo.Type.MIDDLE_RIGHT:
			gizmo.position = Vector2(gpos) + Vector2(gsize.x, gsize.y / 2)
		Gizmo.Type.BOTTOM_RIGHT:
			gizmo.position = Vector2(gpos) + Vector2(gsize.x, gsize.y)
		Gizmo.Type.BOTTOM_CENTER:
			gizmo.position = Vector2(gpos) + Vector2(gsize.x / 2, gsize.y)
		Gizmo.Type.BOTTOM_LEFT:
			gizmo.position = Vector2(gpos) + Vector2(0, gsize.y)
		Gizmo.Type.MIDDLE_LEFT:
			gizmo.position = Vector2(gpos) + Vector2(0, gsize.y / 2)


func get_sizer_pivot_offset(to_size:Vector2i) -> Vector2i:
	var _offset = Vector2i.ZERO
	match pivot:
		GSPivot.TOP_LEFT:
			pass
			
		GSPivot.TOP_CENTER:
			_offset.x = to_size.x / 2.0

		GSPivot.TOP_RIGHT:
			_offset.x = to_size.x

		GSPivot.MIDDLE_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y / 2.0

		GSPivot.BOTTOM_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y

		GSPivot.BOTTOM_CENTER:
			_offset.x = to_size.x / 2.0
			_offset.y = to_size.y

		GSPivot.BOTTOM_LEFT:
			_offset.y = to_size.y

		GSPivot.MIDDLE_LEFT:
			_offset.y = to_size.y / 2.0
		
		GSPivot.CENTER:
			_offset.x = to_size.x / 2.0
			_offset.y = to_size.y / 2.0
			
	return _offset


func get_sizer_position_offset(org_size:Vector2i,
							   to_size:Vector2i) -> Vector2i:
	# DONT DO THIS, when size is very small the result is incorerect.
	# because the int/float precision.
#	var _offset := Pivot.get_pivot_offset(pivot, to_size)
#	var coef :Vector2 = Vector2(_offset) / Vector2(to_size)
#	var size_diff :Vector2 = Vector2(org_rect.size - to_size) * coef
#	var dest_pos :Vector2i = Vector2(org_rect.position) + size_diff

	var _pos = Vector2i.ZERO
	var delta_w := (org_size.x - to_size.x)
	var delta_h := (org_size.y - to_size.y)
	
	match pivot:
		GSPivot.TOP_LEFT:
			pass
			
		GSPivot.TOP_CENTER:
			_pos.x += round(delta_w / 2.0)

		GSPivot.TOP_RIGHT:
			_pos.x += delta_w

		GSPivot.MIDDLE_RIGHT:
			_pos.x += delta_w
			_pos.y += round(delta_h / 2.0)

		GSPivot.BOTTOM_RIGHT:
			_pos.x += delta_w
			_pos.y += delta_h

		GSPivot.BOTTOM_CENTER:
			_pos.x += round(delta_w / 2.0)
			_pos.y = delta_h

		GSPivot.BOTTOM_LEFT:
			_pos.y = delta_h

		GSPivot.MIDDLE_LEFT:
			_pos.y = round(delta_h / 2.0)
		
		GSPivot.CENTER:
			_pos.x = round(delta_w / 2.0)
			_pos.y = round(delta_h / 2.0)
			
	return _pos


func has_area() -> bool:
	# ovrride it very carefully, it might interfere base class funcs.
	return bound_rect.has_area()


func has_point(point :Vector2i) ->bool:
	return bound_rect.has_point(point)


func _input(event :InputEvent):
	# TODO: the way handle the events might not support touch / tablet. 
	# since I have no device to try. leave it for now.

	if not visible:
		return
			
	if event is InputEventKey:
		var delta := 1
		if Input.is_key_pressed(KEY_SHIFT):
			delta = 10
			
		if Input.is_action_pressed('ui_up'):
			move_delta(-delta, VERTICAL)
		
		elif Input.is_action_pressed('ui_right'):
			move_delta(delta, HORIZONTAL)
		
		elif Input.is_action_pressed('ui_down'):
			move_delta(delta, VERTICAL)
		
		elif Input.is_action_pressed('ui_left'):
			move_delta(-delta, HORIZONTAL)
	
	elif event is InputEventMouseMotion:
		var pos := get_local_mouse_position()
		if is_scaling:
			if is_dragging:  # prevent the dragging zone is hit.
				is_dragging = false
			scale_to(pos)
			# it is in a sub viewport, and without any influence with layout.
			# so `get_global_mouse_position()` should work.
		elif is_dragging:
			if is_scaling:
				is_scaling = false
			drag_to(pos)
			# DO NOT check `bound_rect.has_point(pos)` here,
			# that will got bad experience when hit a snap point.
			# when hit a snap point and move faster, it will unexcpet stop.

	elif event is InputEventMouseButton:
		var pos := get_local_mouse_position()
		# its in subviewport local mouse position should be work.
		if is_activated:
			if has_point(pos):
				is_dragging = event.pressed
				if is_dragging:
					drag_offset = Vector2i(pos) - bound_rect.position
				else:
					drag_offset = Vector2i.ZERO
			else:
				if event.pressed and not is_dragging and not is_scaling:
					dismiss()
					# NO NEED check double click here, 
					# pressed always trigger dismiss before double click.
				is_dragging = false

		elif event.pressed and has_point(pos):
			is_dragging = true
			drag_offset = Vector2i(pos) - bound_rect.position
			hire()


func _draw():
	if has_area(): # careful has_area might be ovrride.
		var rect_line_color := line_color
		if not is_activated:
			rect_line_color.a = 0.33
		draw_rect(bound_rect, rect_line_color, false)


func _on_gizmo_hover_updated(gizmo, status):
	gizmo_hover_updated.emit(gizmo, status)
	cursor_changed.emit(gizmo.cursor if status else null)
	

func _on_gizmo_press_updated(gizmo, status):
	gizmo_press_updated.emit(gizmo, status)
	pressed_gizmo = gizmo if status else null


# snapping
func scale_snapping(pos :Vector2i) -> Vector2i:
	return _scale_snapping.call(pos)

func drag_snapping(rect: Rect2i, pos :Vector2i) -> Vector2i:
	return _drag_snapping.call(rect, pos)

# hook for snapping
var _scale_snapping = func(pos :Vector2i) -> Vector2i:
	# pass original postion if no hook.
	return pos

var _drag_snapping = func(_rect: Rect2i, pos :Vector2i) -> Vector2i:
	# pass original postion if no hook.
	return pos

func inject_snapping(scale_callable :Callable, drag_callable :Callable):
	_scale_snapping = scale_callable
	_drag_snapping = drag_callable

# Use custom draw_rect and input event to replace
# what Control (such as ColorRect) should do,
# When `GUI / Snap Controls to Pixels` on Viewport is open.
# will cause a tiny teeny position jumpping, which is unexcepted.
# because the control always try to snap nearest pixel.
# it might happen on any `Control`, have not test on others.
# the Gizmo class is already done when I figure it out,
# so leave it NOT Control for now.
# also seems not much easier to do when use control, 
# still need check the press or not, unless use button.
# but button have much work to do with the style.
# anyway, leave it Node2D for now.
#
# ex., try give the toucher a color and zoom in the camera.
# ```
# toucher = ColorRect.new()
# toucher.size = gizmo_size * 4
# toucher.position = - toucher.size / 2
# print('position ', toucher.position, '/ size /2 ', toucher.size/2)
# ```


class Gizmo extends Node2D :
	
	signal hover_updated(gizmo, status)
	signal press_updated(gizmo, status)
	
	enum Type {
		TOP_LEFT,
		TOP_CENTER,
		TOP_RIGHT,
		MIDDLE_RIGHT,
		BOTTOM_RIGHT,
		BOTTOM_CENTER,
		BOTTOM_LEFT,
		MIDDLE_LEFT,
		CENTER,
	}

	var type := Type.TOP_LEFT

	var color := Color(0.2, 0.2, 0.2, 1) :
		set(val):
			color = val
			queue_redraw()
			
	var bgcolor := Color.WHITE :
		set(val):
			bgcolor = val
			queue_redraw()

	var default_size := Vector2(10, 10) :
		set(val):
			default_size = val
			queue_redraw()

	var size :Vector2 :
		get: return default_size / zoom_ratio
		
	var rectangle :Rect2 :
		get: return Rect2(- gizmo_pos, size)
		
	var touch :Rect2 :
		get: return Rect2(-size, size * 2)
		
	var gizmo_pos :Vector2:
		get = _get_gizmo_pos

	var zoom_ratio := 1.0 :
		set(val):
			zoom_ratio = val
			queue_redraw()

	var cursor := Control.CURSOR_ARROW

	var is_hover := false :
		set(val):
			is_hover = val
			hover_updated.emit(self, is_hover)

	var is_pressed := false:
		set(val):
			is_pressed = val
			press_updated.emit(self, is_pressed)


	func _init(_type):
		visible = false
		type = _type
		
		match type:
			Type.TOP_LEFT:
				cursor = Control.CURSOR_FDIAGSIZE
			Type.TOP_CENTER:
				cursor = Control.CURSOR_VSIZE
			Type.TOP_RIGHT:
				cursor = Control.CURSOR_BDIAGSIZE
			Type.MIDDLE_RIGHT:
				cursor = Control.CURSOR_HSIZE
			Type.BOTTOM_RIGHT:
				cursor = Control.CURSOR_FDIAGSIZE
			Type.BOTTOM_CENTER:
				cursor = Control.CURSOR_VSIZE
			Type.BOTTOM_LEFT:
				cursor = Control.CURSOR_BDIAGSIZE
			Type.MIDDLE_LEFT:
				cursor = Control.CURSOR_HSIZE
			_:
				cursor = Control.CURSOR_POINTING_HAND

	
	func _get_gizmo_pos() -> Vector2: # allow float position
		match type:
			Type.TOP_LEFT:
				return Vector2(size.x, size.y)
			Type.TOP_CENTER:
				return Vector2(size.x/2, size.y)
			Type.TOP_RIGHT:
				return Vector2(0, size.y)
			Type.MIDDLE_RIGHT:
				return Vector2(0, size.y/2)
			Type.BOTTOM_RIGHT:
				return Vector2(0, 0)
			Type.BOTTOM_CENTER:
				return Vector2(size.x/2, 0)
			Type.BOTTOM_LEFT:
				return Vector2(size.x, 0)
			Type.MIDDLE_LEFT:
				return Vector2(size.x, size.y/2)
			Type.CENTER:
				return Vector2(size.x/2, size.y/2)
			_:
				return Vector2.ZERO


	func _draw():
		draw_rect(rectangle, color if is_hover or is_pressed else bgcolor)


	func _input(event :InputEvent):
		if not visible:
			return

		# TODO: the way handle the events might not support touch / tablet. 
		# since I have no device to try. leave it for now.

		if event is InputEventMouse:
			var pos = get_local_mouse_position()
			var hover = touch.has_point(pos)
			if hover:
				if not is_hover:
					is_hover = true
					queue_redraw()  # redraw hover effect
				if event is InputEventMouseButton:
					is_pressed = event.pressed
			else:
				if is_hover:
					is_hover = false
					queue_redraw()  # redraw hover effect
				if is_pressed and event is InputEventMouseButton:
					# for release outside
					is_pressed = false
