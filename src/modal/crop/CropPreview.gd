class_name CropPreview extends TextureRect

const DEFAULT_SIZE := Vector2i(200, 200)

var preview_rect := Rect2i()
var preview_crop_rect := Rect2i()
var frame_line_color := Color.GRAY
var crop_line_color := Color.WHITE

@onready var trans_chekcer := $TransChecker


func _ready():
	size = DEFAULT_SIZE
	custom_minimum_size = DEFAULT_SIZE


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
	
	trans_chekcer.size = img.get_size()
	trans_chekcer.position = (size - trans_chekcer.size) /2
	preview_rect = Rect2i((size - trans_chekcer.size) /2, trans_chekcer.size)
	preview_crop_rect = Rect2i(preview_rect)
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
