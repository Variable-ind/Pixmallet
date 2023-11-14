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
	
	crop_sizer.applied.connect(_on_crop_applied)
	crop_sizer.attached.connect(_on_crop_attached)
#	crop_sizer.activated.connect(_on_crop_activated)
#	crop_sizer.deactivated.connect(_on_crop_deactivated)
	crop_sizer.cursor_changed.connect(_on_cursor_changed)
	crop_sizer.inject_snapping(scale_snapping_hook, drag_snapping_hook)
	
	move_sizer.attached.connect(_on_move_attached)
	move_sizer.activated.connect(_on_move_activated)
	move_sizer.deactivated.connect(_on_move_activated)
	move_sizer.cursor_changed.connect(_on_cursor_changed)
	move_sizer.inject_snapping(scale_snapping_hook, drag_snapping_hook)
	
	color_pick.color_picked.connect(_on_color_picked)
	
	silhouette.before_apply.connect(_on_silhouette_before_apply)
	silhouette.after_apply.connect(_on_silhouette_after_apply)
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
	if project:
		project.current_cel.update_texture()
		queue_redraw()


# temporary prevent canvas operations.
func frozen(frozen_it := false): 
	set_process_input(not frozen_it)


func set_state(val):  # triggered when state changing.
	if state == val:
		return
	
	# leave state
	if state == Operate.CROP:
		crop_sizer.cancel()
		crop_sizer.reset()
	elif state == Operate.MOVE:
		move_sizer.apply()
		move_sizer.reset()
	elif state in Operate.GROUP_SHAPE:
		silhouette.apply()

	state = val
	is_pressed = false
	
	indicator.hide_indicator()  # not all state need indicator
	
	# enter state
	if state == Operate.CROP:
		crop_sizer.launch(project.size)
	elif state == Operate.MOVE:
		move_sizer.launch(project.current_cel.get_image(), selection.mask)


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
			if not drawer.is_drawing:
				history.record(drawer.image)
			drawer.draw_move(pos)
			refresh()
		elif drawer.is_drawing:
			drawer.draw_end(pos)
			history.commit('draw')
			refresh()


func process_selection(event, selector):
	if event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			if not selector.is_operating:
				history.record(selection.mask)
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)
			history.commit('select')


func process_selection_polygon(event, selector):
	if event is InputEventMouseButton:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed and not event.double_click:
			if not selector.is_operating:
				history.record(selection.mask)
			selector.select_move(pos)
		elif selector.is_selecting and event.double_click:
			selector.select_end(pos)
			history.commit('select_polygon')
	elif event is InputEventMouseMotion and selector.is_moving:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			if not selector.is_operating:
				history.record(selection.mask)
			selector.select_move(pos)
		else:
			selector.select_end(pos)
			history.commit('select_polygon')
			

func process_selection_lasso(event, selector):
	if event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			if not selector.is_operating:
				history.record(selection.mask)
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)
			history.commit('select_lasso')


func process_selection_magic(event, selector):
	if event is InputEventMouseButton:
		var pos = get_local_mouse_position()
		if is_pressed:
			if not selector.is_operating:
				history.record(selection.mask)
			selector.image = project.current_cel.get_image()
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)
			history.commit('select_magic')
			
	elif event is InputEventMouseMotion and selector.is_moving:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			if not selector.is_operating:
				history.record(selection.mask)
			selector.select_move(pos)
		elif selector.is_operating:
			selector.select_end(pos)
			history.commit('select_magic')


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
			history.record(bucket.image)
			bucket.fill(pos)
			history.commit('bucket_fill')
			refresh()


func process_shape(event, shaper):
	if event is InputEventMouseButton:
		if is_pressed:
			var pos = get_local_mouse_position()
			if not silhouette.has_touch_point(pos) and silhouette.has_area():
				silhouette.apply()
				# DO NOT do or undo there, apply could trigger by other actions.
				is_pressed = false
				# prevent make unexcept shape right after apply.

			# DO NOT depaned doublie_clieck here, pressed always come first.
	elif event is InputEventMouseMotion:
		var pos = snapper.snap_position(get_local_mouse_position())
		if is_pressed:
			if not shaper.is_operating:
				history.record([
					{'obj': silhouette, 'key': 'current_shaper_type'},
					{'obj': silhouette, 'key': 'shaped_rect'},
					{'obj': silhouette, 'key': 'touch_rect'},
					{'obj': silhouette, 'key': 'start_point'},
					{'obj': silhouette, 'key': 'end_point'},
					{'obj': silhouette, 'key': '_current_shape'},
				], silhouette.update_shape)
			shaper.shape_move(pos)
		elif shaper.is_operating:
			shaper.shape_end(pos)
			history.commit('shape drawn')


func copy():
	var image := project.current_cel.get_image()
	if selection.has_selected():
		var clip_size := selection.selected_rect.size
		var clip_img := Image.create(clip_size.x, clip_size.y,
									 false, image.get_format())
		clip_img.blit_rect_mask(image, selection.mask,
								selection.selected_rect, Vector2i.ZERO)
		Clipboard.set_image(clip_img, selection.selected_rect.position)
	else:
		Clipboard.set_image(image)


func cut():
	copy()
	var image := project.current_cel.get_image()
	if selection.has_selected():
		var cut_img := Image.create(image.get_width(), image.get_height(),
									false, image.get_format())
		cut_img.fill(Color.TRANSPARENT)
		image.blit_rect_mask(cut_img,
							 selection.mask,
							 selection.selected_rect,
							 selection.selected_rect.position)
	else:
		image.fill(Color.TRANSPARENT)
	refresh()


func paste():
	var image := project.current_cel.get_image()
	var pos := Clipboard.get_image_posistion()
	var clip_img := Clipboard.get_image()
	var clip_rect := Rect2i(Vector2i.ZERO, clip_img.get_size())
	
	if selection.has_selected():
		pos = selection.selected_rect.position
		clip_rect.size = selection.selected_rect.size

	image.blend_rect_mask(clip_img, clip_img, clip_rect, pos)
	refresh()


func delete():
	var imgs := []
	for cel in project.selected_cels:
		if not cel is PixelCel or not cel.is_visible:
			continue
		imgs.append(cel.get_image())
		
	history.record(imgs, refresh)
	for img in imgs:
		img.fill(Color.TRANSPARENT)
	
	refresh()
	history.commit('delete')


func select_all():
	history.record(selection.mask, selection.update_selection)
	selection.select_all()
	history.commit('select_all')


func select_deselect():
	history.record(selection.mask, selection.update_selection)
	selection.deselect()
	history.commit('deselect')


func select_invert():
	history.record(selection.mask, selection.update_selection)
	selection.invert()
	history.commit('invert_selection')


func fill_color(color:Color):
	if not project:
		return
	var imgs :Array[Image] = []
	for cel in project.selected_cels:
		if not cel is PixelCel or not cel.is_visible:
			continue
		imgs.append(cel.get_image())
	
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
	history.commit('fill_color')
	


func flip_x():
	var src_img :Image = project.current_cel.get_image()
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
	history.commit('flip_x')
	

func flip_y():
	var src_img :Image = project.current_cel.get_image()
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
	history.commit('flip_y')
	

func rotate_cw():
	var src_img :Image = project.current_cel.get_image()
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
	history.commit('rotate_cw')
	

func rotate_ccw():
	var src_img :Image = project.current_cel.get_image()
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
	history.commit('rotate_ccw')


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


# crop
func _on_crop_applied(crop_rect :Rect2i):
	project.crop_to(crop_rect)


func _on_crop_attached(_rect, _rel_pos):
	history.record([
		{'obj': crop_sizer, 'key': 'bound_rect'},
	], [
		{'action': crop_sizer.hire, 'is_do': true},
		{'action': crop_sizer.dismiss, 'is_undo': true}
	])
	history.commit('crop_start')


# move
func _on_move_attached(_rect, _rel_pos):
	print(_rect)
	history.record([
		{'obj': move_sizer, 'key': 'bound_rect'},
		{'obj': move_sizer, 'key': 'preview_texture'}
	], [
		{'action': move_sizer.hire, 'is_do': true},
		{'action': move_sizer.dismiss, 'is_undo': true}
	])
	history.commit('move_start')


func _on_move_activated(_rect, _rel_pos):
	history.record([
		{'obj': move_sizer, 'key': 'bound_rect'},
		{'obj': move_sizer, 'key': 'preview_texture'}
	], [
		{'action': move_sizer.hire, 'is_do': true},
		{'action': move_sizer.dismiss, 'is_undo': true}
	])
	history.commit('move_activated')
	refresh()


func _on_move_deactivated(_rect, _rel_pos):
	history.record([
		{'obj': move_sizer, 'key': 'bound_rect'},
		{'obj': move_sizer, 'key': 'preview_texture'}
	], [
		{'action': move_sizer.hire, 'is_do': true},
		{'action': move_sizer.dismiss, 'is_undo': true}
	])
	history.commit('move_deactivated')
	refresh()


# silhouette
func _on_silhouette_before_apply():
	history.record([
		silhouette.image,
		{'obj': silhouette, 'key': 'current_shaper_type'},
		{'obj': silhouette, 'key': 'shaped_rect'},
		{'obj': silhouette, 'key': 'touch_rect'},
		{'obj': silhouette, 'key': 'start_point'},
		{'obj': silhouette, 'key': 'end_point'},
		{'obj': silhouette, 'key': '_current_shape'},
	], silhouette.update_shape)


func _on_silhouette_after_apply():
	history.commit('shape applied')
	refresh()


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

