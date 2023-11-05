class_name ImgPreview extends TextureRect

const MIN_SIZE := Vector2i(200, 200)

var preview_rect := Rect2i()
var bgcolor := Color.GRAY

@onready var trans_checker := $TransChecker
@onready var msg_empty := $MsgEmpty


func _ready():
	custom_minimum_size = MIN_SIZE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	msg_empty.hide()


func render(img :Image, check_visible := true):
	img = img.duplicate()  # prevent image unexcept changes.
	var img_width :float = img.get_width()
	var img_height :float = img.get_height()
	var _width :int = floor(size.x)
	var _height :int = floor(size.y)
	
	if img_width > img_height:
		_height = floor(size.y * img_height / img_width)
	else:
		_width =  floor(size.x * img_width / img_height)
	
	img.resize(_width, _height, Image.INTERPOLATE_NEAREST)
	
	trans_checker.size = img.get_size()
	trans_checker.position = (size - trans_checker.size) /2
	
#	# preview_rect to draw a rect outline.
#	# but the texture will center of the TextureRect
#	# by the setting of properties.
	preview_rect = Rect2i(
		(size - trans_checker.size) /2, 
		trans_checker.size
	)
	
	if check_visible:
		check_preview_visible(img)
	else:
		trans_checker.show()
		msg_empty.hide()

	if trans_checker.visible:
		texture = ImageTexture.create_from_image(img)
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	queue_redraw()


func set_preview_material(params:Dictionary):
	for param in params:
		material.set_shader_parameter(param, params[param])


func update_material(params:Dictionary):
	for param in params:
		material.set_shader_parameter(param, params[param])


func check_preview_visible(img):
	if img.is_invisible():
		trans_checker.hide()
		msg_empty.show()
	else:
		trans_checker.show()
		msg_empty.hide()


func _draw():
	if preview_rect.has_area() and not trans_checker.visible:
		draw_rect(preview_rect, bgcolor)
