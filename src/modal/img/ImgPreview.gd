class_name ImgPreview extends TextureRect

const MIN_SIZE := Vector2i(200, 200)

var preview_rect := Rect2i()
var frame_line_color := Color.GRAY

@onready var trans_checker := $TransChecker
@onready var msg_empty := $MsgEmpty


func _ready():
	custom_minimum_size = MIN_SIZE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	resized.connect(make_placement)
	msg_empty.hide()


func update_texture(img :Image):
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
	make_placement()
	
	if img.is_invisible():
		trans_checker.hide()
		msg_empty.show()
	else:
		trans_checker.show()
		msg_empty.hide()
		texture = ImageTexture.create_from_image(img)
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	queue_redraw()


func make_placement():
	# the `Preview` might stretch when display.
	trans_checker.position = (size - trans_checker.size) /2
	preview_rect = Rect2i((size - trans_checker.size) /2, trans_checker.size)


func _draw():
	if preview_rect.has_area():
		draw_rect(preview_rect, frame_line_color, false, 2)
