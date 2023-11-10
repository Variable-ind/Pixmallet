class_name Canvas extends Node2D

signal color_picked(color)
signal cropped(crop_rect)
signal cursor_changed(cursor)
signal operating(operate_state, is_finished)
# let parent to know when should block some other actions.
# for improve useblilty.


var state := Operate.NONE:
	set = set_state

var project :Project
var current_operator :Variant = null
var size :Vector2i :
	get:
		if project:
			return project.size
		else:
			return Vector2i.ZERO

const DEFAULT_PEN_PRESSURE := 1.0
const DEFAULT_PEN_VELOCITY := 1.0

var pressure_min_thres := 0.0
var pressure_max_thres := 1.0
var velocity_min_thres := 0.0
var velocity_max_thres := 1.0

var snapper := Snapper.new()

var is_pressed := false

var zoom := Vector2.ONE :
	set = set_zoom_ratio


var color_pick := ColorPick.new()

@onready var indicator :Indicator = $Indicator
@onready var selection :Selection = $Selection
@onready var crop_sizer :CropSizer = $CropSizer
@onready var move_sizer :MoveSizer = $MoveSizer
@onready var silhouette :Silhouette = $Silhouette

@onready var selector_rectangle := RectSelector.new(selection)
@onready var selector_ellipse := EllipseSelector.new(selection)
@onready var selector_polygon := PolygonSelector.new(selection)
@onready var selector_lasso := LassoSelector.new(selection)
@onready var selector_magic := MagicSelector.new(selection)

@onready var drawer_pencil := PencilDrawer.new(selection.mask)
@onready var drawer_brush := BrushDrawer.new(selection.mask)
@onready var drawer_eraser := EraseDrawer.new(selection.mask)
@onready var drawer_shading := ShadingDrawer.new(selection.mask)

@onready var bucket := Bucket.new(selection.mask)

@onready var shaper_rectangle := RectShaper.new(silhouette)
@onready var shaper_ellipse := EllipseShaper.new(silhouette)
@onready var shaper_line := LineShaper.new(silhouette)
@onready var shaper_polygon := PolygonShaper.new(silhouette)
#var mirror_view :bool = false
#var draw_pixel_grid :bool = false
#var grid_draw_over_tile_mode :bool = false
#var shape_perfect :bool = false
#var shape_center :bool = false

#var onion_skinning :bool = false
#var onion_skinning_past_rate := 1.0
#var onion_skinning_future_rate := 1.0

#@onready var tile_mode :Node2D = $TileMode
#@onready var onion_past :Node2D = $OnionPast
#@onready var onion_future :Node2D = $OnionFuture


func _ready():
#	onion_past.type = onion_past.PAST
#	onion_past.blue_red_color = Color.RED
#	onion_future.type = onion_future.FUTURE
#	onion_future.blue_red_color = Color.BLUE
	
	var scale_snapping_hook = func(pos :Vector2i) -> Vector2i:
		return snapper.snap_position(pos, true)
	
	var drag_snapping_hook = func(rect:Rect2i, pos :Vector2i) -> Vector2i:
		return snapper.snap_boundary_position(rect, pos)
	
	crop_sizer.crop_canvas.connect(crop)
	crop_sizer.cursor_changed.connect(_on_cursor_changed)
	crop_sizer.inject_snapping(scale_snapping_hook, drag_snapping_hook)
	
	move_sizer.refresh_canvas.connect(refresh)
	move_sizer.cursor_changed.connect(_on_cursor_changed)
	move_sizer.inject_snapping(scale_snapping_hook, drag_snapping_hook)
	
	bucket.color_filled.connect(refresh)
	color_pick.color_picked.connect(_on_color_picked)
	
	silhouette.refresh_canvas.connect(refresh)
	silhouette.inject_snapping(drag_snapping_hook)
	
	selection.inject_snapping(drag_snapping_hook)


func attach_project(proj):
	project = proj
	
	selection.size = project.size
	
	silhouette.attach(project.current_cel.get_image())
	
	drawer_brush.attach(project.current_cel.get_image())
	drawer_pencil.attach(project.current_cel.get_image())
	drawer_eraser.attach(project.current_cel.get_image())
	drawer_shading.attach(project.current_cel.get_image())
	
	bucket.attach(project.current_cel.get_image())
	set_state(state)  # trigger state changing to init settings.


func refresh():
	project.current_cel.update_texture()
	queue_redraw()


func crop(crop_rect :Rect2i):
	project.crop_to(crop_rect)
	

# temporary prevent canvas operations.
func frozen(frozen_it := false): 
	set_process_input(not frozen_it)


func set_state(val):  # triggered when state changing.
	# allow change without really changed val, trigger funcs in setter.
	state = val
	is_pressed = false
	
	indicator.hide_indicator()  # not all state need indicator
	
	if state == Operate.CROP:
		silhouette.terminate(true)
		move_sizer.terminate(true)
		crop_sizer.launch(project.size)
		selection.deselect()
	elif state == Operate.MOVE:
		silhouette.terminate(true)
		crop_sizer.terminate(false)
		move_sizer.lanuch(project.current_cel.get_image(), selection.mask)
		# selection must clear after mover setted, 
		# mover still need it once.
		selection.deselect()
	else:
		silhouette.terminate(true)
		move_sizer.terminate(true)
		crop_sizer.terminate(false)


func set_zoom_ratio(val):
	if zoom == val:
		return
	zoom = val
	var zoom_ratio = (zoom.x + zoom.y) / 2
	selection.zoom_ratio = zoom_ratio
	crop_sizer.zoom_ratio = zoom_ratio
	move_sizer.zoom_ratio = zoom_ratio


func prepare_pressure(pressure:float) -> float:
	if pressure == 0.0:
		# when the device pressure is not supported will always be 0.0
		# use it with button pressed check some where.
		return 1.0
	pressure = remap(pressure, pressure_min_thres, pressure_max_thres, 0.0, 1.0)
	pressure = clampf(pressure, 0.0, 1.0)
	return pressure


func prepare_velocity(mouse_velocity:Vector2i) -> float:
	# convert velocity to 0.0~1.0
	var velocity = mouse_velocity.length() / 1000.0 
	
	velocity = remap(velocity, velocity_min_thres, velocity_max_thres, 0.0, 1.0)
	velocity = clampf(velocity, 0.0, 1.0)
	return 1 - velocity  # more fast should be more week.


func process_drawing_or_erasing(event, drawer):
	if event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		indicator.show_indicator(pos, drawer.stroke_dimensions)

		if (not drawer.can_draw(pos) or
			not project.current_cel is PixelCel):
			return
		
		if is_pressed:
			match drawer.dynamics_stroke_width:
				Dynamics.PRESSURE:
					drawer.set_stroke_width_dynamics(
						prepare_pressure(event.pressure))
				Dynamics.VELOCITY:
					drawer.set_stroke_width_dynamics(
						prepare_velocity(event.velocity))
				_:
					drawer.set_stroke_width_dynamics() # back to default
			match drawer.dynamics_stroke_alpha:
				Dynamics.PRESSURE:
					drawer.set_stroke_alpha_dynamics(
						prepare_pressure(event.pressure))
				Dynamics.VELOCITY:
					drawer.set_stroke_alpha_dynamics(
						prepare_velocity(event.velocity))
				_:
					drawer.set_stroke_alpha_dynamics() # back to default
			drawer.draw_move(pos)
			refresh()
		elif drawer.is_drawing:
			drawer.draw_end(pos)
			refresh()


func process_selection(event, selector):
	if event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)


func process_selection_polygon(event, selector):
	if event is InputEventMouseButton:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed and not event.double_click:
			selector.select_move(pos)
		elif selector.is_selecting and event.double_click:
			selector.select_end(pos)
	elif event is InputEventMouseMotion and selector.is_moving:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			selector.select_move(pos)
		else:
			selector.select_end(pos)
			

func process_selection_lasso(event, selector):
	if event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)


func process_selection_magic(event, selector):
	if event is InputEventMouseButton:
		var pos = get_local_mouse_position()
		if is_pressed:
			selector.image = project.current_cel.get_image()
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)
			
	elif event is InputEventMouseMotion and selector.is_moving:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)


func process_color_pick(event):
	if event is InputEventMouseButton:
		if is_pressed:
			color_pick.merge_image(project.current_frame.get_images(),
								   PixelCel.IMAGE_FORMAT)
	elif event is InputEventMouseMotion:
		if is_pressed:
			var pos = get_local_mouse_position()
			color_pick.pick(pos)


func process_bucket_fill(event):
	if event is InputEventMouseButton:
		if is_pressed:
			var pos = get_local_mouse_position()
			history.record(bucket.image, refresh)
			bucket.fill(pos)
			history.commit()


func process_shape(event, shaper):
	if event is InputEventMouseButton:
		if is_pressed:
			var pos = get_local_mouse_position()
			if not silhouette.has_touch_point(pos) and silhouette.has_area():
				shaper.apply()
				is_pressed = false
				# prevent make unexcept shape right after apply.

			# DO NOT depaned doublie_clieck here, pressed always come first.
	elif event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			shaper.shape_move(pos)
		elif shaper.is_operating:
			shaper.shape_end(pos)


func select_all():
	history.record(selection.mask, selection.update_selection)
	selection.select_all()
	history.commit()


func select_deselect():
	history.record(selection.mask, selection.update_selection)
	selection.deselect()
	history.commit()


func select_invert():
	history.record(selection.mask, selection.update_selection)
	selection.invert()
	history.commit()


func fill_color(color:Color):
	if not project:
		return
	var imgs :Array[Image] = []
	for cel in project.selected_cels:
		if not cel is PixelCel or not cel.is_visible:
			continue
		var image = cel.get_image()
		imgs.append(image)
	
	history.record(imgs, refresh)
		
	for image in imgs:
		if selection.has_selected():
			var tmp_img := Image.create(image.get_width(),
										image.get_height(),
										false, image.get_format())
			tmp_img.fill(color)
			image.blit_rect_mask(tmp_img,
								 selection.mask, 
								 Rect2i(Vector2i.ZERO, image.get_size()),
								 Vector2i.ZERO)
		else:
			image.fill(color)
	
	refresh()
	history.commit()
	


func flip_x():
	var src_img := project.current_cel.get_image()
	history.record(src_img, refresh)
	if selection.has_selected():
		var rect := selection.selected_rect
		
		var blank := Image.create(src_img.get_width(), src_img.get_height(), 
								  false, src_img.get_format())
		var img := Image.create(src_img.get_width(), src_img.get_height(),
								false, src_img.get_format())
		img.blit_rect_mask(src_img, selection.mask, rect, rect.position)
		src_img.blit_rect_mask(blank, selection.mask, rect, rect.position)
		
		img = img.get_region(rect)
		img.flip_x()
		
		history.record(selection.mask, selection.update_selection)
		selection.flip_x()
		src_img.blit_rect_mask(img, 
							   selection.get_mask_region(), 
							   selection.get_mask_rect(),
							   rect.position)
	else:
		src_img.flip_x()

	refresh()
	history.commit()
	

func flip_y():
	var src_img := project.current_cel.get_image()
	history.record(src_img, refresh)
	if selection.has_selected():
		var rect := selection.selected_rect
		var blank := Image.create(src_img.get_width(), src_img.get_height(), 
								  false, src_img.get_format())
		var img := Image.create(src_img.get_width(), src_img.get_height(),
								false, src_img.get_format())
		
		img.blit_rect_mask(src_img, selection.mask, rect, rect.position)
		src_img.blit_rect_mask(blank, selection.mask, rect, rect.position)
		
		img = img.get_region(rect)
		img.flip_y()
		
		history.record(selection.mask, selection.update_selection)
		selection.flip_y()
		src_img.blit_rect_mask(img,
							   selection.get_mask_region(),
							   selection.get_mask_rect(),
							   rect.position)
	else:
		src_img.get_image().flip_y()

	refresh()
	history.commit()
	

func rotate_cw():
	var src_img := project.current_cel.get_image()
	history.record(src_img, refresh)
	if selection.has_selected():
		var rect := selection.selected_rect
		
		var blank := Image.create(src_img.get_width(), src_img.get_height(), 
								  false, src_img.get_format())
		var img := Image.create(src_img.get_width(), src_img.get_height(),
								false, src_img.get_format())
		
		img.blit_rect_mask(src_img, selection.mask, rect, rect.position)
		src_img.blit_rect_mask(blank, selection.mask, rect, rect.position)
		
		img = img.get_region(rect)
		img.rotate_90(CLOCKWISE)
		
		history.record(selection.mask, selection.update_selection)
		selection.rotate_90(CLOCKWISE)
		src_img.blit_rect_mask(img, img, selection.get_mask_rect(),
							   selection.selected_rect.position)
	else:
		var w: = src_img.get_width()
		var h: = src_img.get_height()
		
		var rotate_img := src_img.duplicate()
		rotate_img.rotate_90(CLOCKWISE)
		var rotate_rect := Rect2i(Vector2i.ZERO, rotate_img.get_size())
		var dst = Vector2i(
			floor((w - rotate_rect.size.x) * 0.5),
			floor((h - rotate_rect.size.y) * 0.5)
		)
		src_img.fill(Color.TRANSPARENT)
		src_img.blit_rect(rotate_img, rotate_rect, dst)

	refresh()
	history.commit()
	

func rotate_ccw():
	var src_img := project.current_cel.get_image()
	history.record(src_img, refresh)
	
	if selection.has_selected():
		var rect := selection.selected_rect
		var blank := Image.create(src_img.get_width(), src_img.get_height(), 
								  false, src_img.get_format())
		var img := Image.create(src_img.get_width(), src_img.get_height(),
								false, src_img.get_format())
		
		img.blit_rect_mask(src_img, selection.mask, rect, rect.position)
		src_img.blit_rect_mask(blank, selection.mask, rect, rect.position)
		
		img = img.get_region(rect)
		img.rotate_90(COUNTERCLOCKWISE)
		
		selection.rotate_90(COUNTERCLOCKWISE)
		src_img.blit_rect_mask(img, img, selection.get_mask_rect(),
							   selection.selected_rect.position)
	else:
		var w: = src_img.get_width()
		var h: = src_img.get_height()
		
		var rotate_img := src_img.duplicate()
		rotate_img.rotate_90(COUNTERCLOCKWISE)
		var rotate_rect := Rect2i(Vector2i.ZERO, rotate_img.get_size())
		var dst = Vector2i(
			floor((w - rotate_rect.size.x) * 0.5),
			floor((h - rotate_rect.size.y) * 0.5)
		)
		src_img.fill(Color.TRANSPARENT)
		src_img.blit_rect(rotate_img, rotate_rect, dst)
		
	refresh()
	history.commit()


func _input(event :InputEvent):
	if not project.current_cel:
		return
	
	if event is InputEventMouseButton:
		is_pressed = event.pressed
		operating.emit(state, not is_pressed)

	match state:
		Operate.PENCIL:
			process_drawing_or_erasing(event, drawer_pencil)
		Operate.BRUSH:
			process_drawing_or_erasing(event, drawer_brush)
		Operate.ERASE:
			process_drawing_or_erasing(event, drawer_eraser)
		Operate.SHADING:
			process_drawing_or_erasing(event, drawer_shading)
		Operate.CROP:
			pass
		Operate.MOVE:
			pass
		Operate.SELECT_RECTANGLE:
			process_selection(event, selector_rectangle)
		Operate.SELECT_ELLIPSE:
			process_selection(event, selector_ellipse)
		Operate.SELECT_POLYGON:
			process_selection_polygon(event, selector_polygon)
		Operate.SELECT_LASSO:
			process_selection_lasso(event, selector_lasso)
		Operate.SELECT_MAGIC:
			process_selection_magic(event, selector_magic)
		Operate.SHAPE_RECTANGLE:
			process_shape(event, shaper_rectangle)
		Operate.SHAPE_ELLIPSE:
			process_shape(event, shaper_ellipse)
		Operate.SHAPE_LINE:
			process_shape(event, shaper_line)
		Operate.SHAPE_POLYGON:
			process_shape(event, shaper_polygon)
		Operate.COLORPICK:
			process_color_pick(event)
		Operate.BUCKET:
			process_bucket_fill(event)


func _draw():
	if not project or not project.current_cel:
		return

	# Draw current frame layers
	for i in project.layers.size():
		var cels = project.current_frame.cels 
		if cels[i] is GroupCel:
			continue
		var modulate_color := Color(1, 1, 1, project.layers[i].opacity)
		if project.layers[i].is_visible_in_hierarchy():
			var tex = cels[i].image_texture
			draw_texture(tex, Vector2.ZERO, modulate_color)


func get_relative_mouse_position() -> Vector2i: # mouse location of canvas.
	var mpos = get_local_mouse_position()
	return Vector2i(round(mpos.x), round(mpos.y))


# cursor
func _on_cursor_changed(cursor):
	cursor_changed.emit(cursor)


# color
func _on_color_picked(color):
	color_picked.emit(color)


# snapping

func attach_snap_to(canvas_size:Vector2, guides:Array,
					symmetry_guide:SymmetryGuide, grid:Grid):
	snapper.guides = guides
	snapper.grid = grid
	snapper.symmetry_guide = symmetry_guide
	snapper.canvas_size = canvas_size


var snap_to_guide :bool :
	get: return snapper.snap_to_guide
	set(val): snapper.snap_to_guide = val


var snap_to_grid_center :bool :
	get: return snapper.snap_to_grid_center
	set(val): snapper.snap_to_grid_center = val


var snap_to_grid_boundary :bool :
	get: return snapper.snap_to_grid_boundary
	set(val): snapper.snap_to_grid_boundary = val

var snap_to_symmetry_guide :bool :
	get: return snapper.snap_to_symmetry_guide
	set(val): snapper.snap_to_symmetry_guide = val

