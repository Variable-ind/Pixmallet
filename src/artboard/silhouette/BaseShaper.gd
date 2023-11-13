class_name BaseShaper extends RefCounted

enum {
	NONE,
	RECTANGLE,
	ELLIPSE,
	LINE,
	POLYGON,
}
var type := NONE

var silhouette : Silhouette

var points :PackedVector2Array = []
var drag_offset := Vector2i.ZERO

var is_shaping := false
var is_dragging := false

var is_operating :bool :
	get: return is_shaping or is_dragging


func _init(_silhouette :Silhouette):
	silhouette = _silhouette
#	silhouette.applied.connect(_on_applied)
#	silhouette.canceled.connect(_on_canceled)
	# DO NOT use signal to separate different shaper is current using.
	# even shaper do not have _input event.
	# but DO NOT silhouette can emit signal when key event is triggered.
	# that will mess up UndoRedo rulers. 


func reset():
	drag_offset = Vector2i.ZERO
	points.clear()
	is_shaping = false
	is_dragging = false
	silhouette.reset()


func shape_start(pos :Vector2i):
	if silhouette.has_touch_point(pos):
		is_dragging = true
		drag_offset = silhouette.get_drag_offset(pos)
	else:
		reset()  # must reset here because silhouette not working a image.
		is_shaping = true
		points.append(pos)


func shape_move(pos :Vector2i):
	if not is_operating:
		shape_start(pos)


func shape_end(_pos :Vector2i):
	is_shaping = false
	is_dragging = false
	silhouette.current_shaper_type = type

