class_name ImgPreview extends TextureRect

const DEFAULT_SIZE := Vector2i(200, 200)

var preview_rect := Rect2i()
var frame_line_color := Color.GRAY

@onready var trans_chekcer := $TransChecker
@onready var msg_empty := $MsgEmpty


func _ready():
	size = DEFAULT_SIZE
	custom_minimum_size = DEFAULT_SIZE
	msg_empty.hide()


func update_texture(img :Image):
	var img_width :float = img.get_width()
	var img_height :float = img.get_height()
	print(size)
	var _width :int = floor(size.x)
	var _height :int = floor(size.y)
	if img_width > img_height:
		_height = floor(size.y * img_height / img_width)
	else:
		_width =  floor(size.x * img_width / img_height)

	img.resize(_width, _height, Image.INTERPOLATE_NEAREST)
	print(img.get_size())
	
	trans_chekcer.size = img.get_size()
	trans_chekcer.position = (size - trans_chekcer.size) /2
	preview_rect = Rect2i((size - trans_chekcer.size) /2, trans_chekcer.size)
	print(preview_rect, size, ' w:', img.get_width(), ' h:', img.get_height())
#	if img.is_invisible():
#		trans_chekcer.hide()
#		msg_empty.show()
#	else:
#		trans_chekcer.show()
#		msg_empty.hide()
#		texture = ImageTexture.create_from_image(img)
#		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture = ImageTexture.create_from_image(img)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
#	queue_redraw()
	print(img.get_size())


func _draw():
	if preview_rect.has_area():
		draw_rect(preview_rect, frame_line_color, false, 2)
#	draw_rect(Rect2i(Vector2i.ZERO, size), Color.RED)
#	print(size)
