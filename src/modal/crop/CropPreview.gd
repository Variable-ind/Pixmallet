class_name CropPreview extends TextureRect

const MIN_SIZE := Vector2i(200, 200)

var preview_rect := Rect2i()
var preview_crop_rect := Rect2i()
var frame_line_color := Color.GRAY
var crop_line_color := Color.WHITE

@onready var trans_checker := $TransChecker


func _ready():
	custom_minimum_size = MIN_SIZE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	resized.connect(make_placement)


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
	texture = ImageTexture.create_from_image(img)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func update_rect(rect :Rect2, base_size :Vector2):
	var ratio_x :float = preview_rect.size.x / base_size.x
	var ratio_y :float = preview_rect.size.y / base_size.y
	preview_crop_rect.size.x = floor(rect.size.x * ratio_x)
	preview_crop_rect.size.y = floor(rect.size.y * ratio_y)
	var to_pos_x = floor(rect.position.x * ratio_x)
	var to_pos_y = floor(rect.position.y * ratio_y)
	preview_crop_rect.position.x = preview_rect.position.x + to_pos_x
	preview_crop_rect.position.y = preview_rect.position.y + to_pos_y
	queue_redraw()


func _draw():
	if preview_rect.has_area():
		draw_rect(preview_rect, frame_line_color, false, 2)
	if preview_crop_rect.has_area():
		draw_rect(preview_crop_rect, crop_line_color, false, 2)


func make_placement():
	# the `Preview` might stretch when display.
	trans_checker.position = (size - trans_checker.size) /2
	preview_rect = Rect2i((size - trans_checker.size) /2, trans_checker.size)
	preview_crop_rect = Rect2i(preview_rect)
