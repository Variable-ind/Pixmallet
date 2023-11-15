class_name MoveSizer extends GizmoSizer

signal applied(rect)
signal canceled

const MODULATE_COLOR := Color(1, 1, 1, 0.66)

var image := Image.new()

var selection :Selection
var was_selection := false

var backup_image := Image.new()  # a backup image for cancel.
var backup_rect := Rect2i()  # a backup rect for cancel.
var backup_mask := Image.new()  # a backup selection mask for cancel.

var preview_texture := ImageTexture.new()
var preview_image := Image.new() :
	set(val):
		preview_image = val
		update_texture()


func _ready():
	super._ready()
	updated.connect(_on_updated)


func reset():
	super.reset()
	backup_rect = Rect2i()
	preview_texture = ImageTexture.new()
	preview_image = Image.new()
	image = Image.new()
	backup_image = Image.new()


func launch(img :Image, _selection :Selection):
	reset()
	image = img  # DO NOT copy_form, image must change runtime.
	selection = _selection  # DO NOT copy_form, selection must change runtime.
	was_selection = selection.has_selected()
	backup_image.copy_from(image)
	backup_mask.copy_from(selection.mask)

	if selection.has_selected():
		backup_rect = selection.selected_rect
	else:
		backup_rect = image.get_used_rect()
	
	preview_image = create_preview_image(backup_rect, image, selection.mask)
	attach(backup_rect)


func cancel():
	image.copy_from(backup_image)
	selection.mask.copy_from(backup_mask)
	bound_rect = backup_rect
	preview_image = create_preview_image(bound_rect, image, selection.mask)
	dismiss()
	canceled.emit()


func apply():
	if has_area():
		# NO NEED resize image here, already did _on_updated.
#		preview_image.resize(bound_rect.size.x,
#							 bound_rect.size.y,
#							 Image.INTERPOLATE_NEAREST)
		# DO NOT just fill rect, selection might have different shapes.
		image.blit_rect_mask(preview_image, preview_image,
							 Rect2i(Vector2i.ZERO, bound_rect.size),
							 bound_rect.position)
		if selection.has_selected():
			bound_rect = selection.selected_rect
		else:
			bound_rect = image.get_used_rect()
		backup_image.copy_from(image)
		backup_mask.copy_from(selection.mask)
		backup_rect = bound_rect
#		preview_image.fill(Color.TRANSPARENT)
		applied.emit(bound_rect)


func hire():
	if is_activated:
		return
	# image will not change and cancelable while in the progress.
	# until applied or canceld.
	if selection.has_selected():
		preview_image = create_preview_image(bound_rect, image, selection.mask)
		
		# use _tmp another way.
		var _tmp = Image.create(image.get_width(), image.get_height(),
								false, image.get_format())
		_tmp.fill(Color.TRANSPARENT)
#			image.fill_rect(move_rect, Color.TRANSPARENT)
		# DO NOT just fill rect, selection might have different shapes.
		image.blit_rect_mask(_tmp, selection.mask, 
							 bound_rect, bound_rect.position)
	else:
		# for whole image
		preview_image = image.get_region(bound_rect)
		image.fill_rect(bound_rect, Color.TRANSPARENT)
		
	super.hire()


func create_preview_image(rect:Rect2i, img:Image, mask:Image):
	var tmp := Image.create(rect.size.x, rect.size.y, false, img.get_format())
	tmp.blit_rect_mask(image, mask, rect, Vector2i.ZERO)
	return tmp


func update_texture():
	if preview_image.is_empty():
		preview_texture = ImageTexture.new()
	else:
		preview_texture.set_image(preview_image)


func _draw():
	if has_area(): # careful has_area might be ovrride.
		if is_activated:
	#		texture = ImageTexture.create_from_image(image)
			# DO NOT new a texture here, may got blank texture. do it before.
			draw_texture_rect(preview_texture, bound_rect, false,
							  MODULATE_COLOR if is_dragging else Color.WHITE)
	super._draw()


func _input(event :InputEvent):
	# TODO: the way handle the events might not support touch / tablet. 
	# since I have no device to try. leave it for now.

	if not visible:
		return
			
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER) and \
		   event.is_command_or_control_pressed():
			apply()
		elif Input.is_key_pressed(KEY_ESCAPE):
			cancel()
	
	var tmp_is_activated := is_activated
	
	super._input(event)
	
	var is_dismissed := (is_activated == false and tmp_is_activated == true)
	
	if event is InputEventMouseButton:
		if is_dismissed:
			apply()


func _on_updated(rect, _rel_pos, _status):
#	var img := RenderingServer.texture_2d_get(preview_texture.get_rid())
#	preview_image.copy_from(img)

	preview_image.resize(bound_rect.size.x, 
						 bound_rect.size.y,
						 Image.INTERPOLATE_NEAREST)
	update_texture()
	
	if was_selection:
		# also the image mask must update, because already transformed.
		var to_rect = Rect2i(Vector2i.ZERO, rect.size)
		var sel_img := preview_image.duplicate()
		sel_img.convert(selection.mask.get_format())
		selection.update(sel_img, to_rect, rect.position)
