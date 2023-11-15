class_name MoveSizer extends GizmoSizer

signal applied(rect)
signal canceled

const MODULATE_COLOR := Color(1, 1, 1, 0.66)

var image := Image.new()
var image_backup := Image.new()  # a backup image for cancel.
var image_mask := Image.new()  # pass selection mask

var backup_rect := Rect2i()

var preview_texture := ImageTexture.new()
var preview_image := Image.new() :
	set(val):
		preview_image = val
		update_texture()


func reset():
	super.reset()
	backup_rect = Rect2i()
	preview_texture = ImageTexture.new()
	preview_image = Image.new()
	image = Image.new()
	image_mask = Image.new()
	image_backup = Image.new()


func launch(img :Image, mask :Image):
	reset()
	image = img  # DO NOT copy_form, image must change runtime.
	image_backup.copy_from(image)
	image_mask.copy_from(mask)
	if image_mask.is_empty() or image_mask.is_invisible():
		backup_rect = image.get_used_rect()
	else:
		backup_rect = image_mask.get_used_rect()
	preview_image = image.get_region(backup_rect)
	attach(backup_rect)


func cancel():
	image.copy_from(image_backup)
	bound_rect = backup_rect
	preview_image.fill(Color.TRANSPARENT)
	dismiss()
	canceled.emit()


func apply():
	if has_area():
		preview_image.resize(bound_rect.size.x,
							 bound_rect.size.y,
							 Image.INTERPOLATE_NEAREST)
		# DO NOT just fill rect, selection might have different shapes.
		image.blit_rect_mask(preview_image, preview_image,
							 Rect2i(Vector2i.ZERO, bound_rect.size),
							 bound_rect.position)
		image_backup.copy_from(image)
		backup_rect = bound_rect
		# also the image mask must update, because already transformed.
		var _mask = Image.create(image.get_width(), image.get_height(),
								 false, image.get_format())
		_mask.blit_rect(preview_image,
						Rect2i(Vector2i.ZERO, bound_rect.size),
						bound_rect.position)
		image_mask.copy_from(_mask)
		preview_image.fill(Color.TRANSPARENT)
		applied.emit(bound_rect)
	dismiss()


func hire():
	if is_activated:
		return
	# image will not change and cancelable while in the progress.
	# until applied or canceld.
	if image_mask.is_empty() or image_mask.is_invisible():
		# for whole image
		preview_image = image.get_region(bound_rect)
		image.fill_rect(bound_rect, Color.TRANSPARENT)
	else:
		# use tmp image for trigger the setter of transformer_image
		var _tmp = Image.create(bound_rect.size.x, 
								bound_rect.size.y,
								false, image.get_format())
		_tmp.blit_rect_mask(image, image_mask, bound_rect, Vector2i.ZERO)
		preview_image = _tmp.duplicate()
					
		_tmp.resize(image.get_width(), image.get_height())
		_tmp.fill(Color.TRANSPARENT)
#			image.fill_rect(move_rect, Color.TRANSPARENT)
		# DO NOT just fill rect, selection might have different shapes.
		image.blit_rect_mask(_tmp, image_mask, 
							 bound_rect, bound_rect.position)
	super.hire()


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
