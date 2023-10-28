class_name CropPreview extends TextureRect

const DEFAULT_SIZE := Vector2i(200, 200)

var preview_rect := Rect2i()
var line_color := Color.WHITE


func _ready():
	size = DEFAULT_SIZE
	custom_minimum_size = DEFAULT_SIZE


func update_image(img):
	var img_width :float = img.get_width()
	var img_height :float = img.get_height()
	if img_width > img_height:
		img.resize(size.x, floor(size.y * img_height / img_width),
				   Image.INTERPOLATE_NEAREST)
	else:
		img.resize(floor(size.x * img_width / img_height), size.y,
				   Image.INTERPOLATE_NEAREST)
	texture = ImageTexture.create_from_image(img)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func update_rect(rect):
	var ratio := 1.0
	if rect.size.x > rect.size.y:
		ratio = rect.size.y / float(rect.size.x)
	else:
		ratio = rect.size.x / float(rect.size.y)
	preview_rect = Rect2i(rect.position * ratio, rect.size * ratio)
	queue_redraw()


func _draw():
	if preview_rect.has_area():
		draw_rect(preview_rect, line_color, false, 2)
	print(size, custom_minimum_size)
#	draw_rect(Rect2i(Vector2i.ZERO, size), line_color)
		
