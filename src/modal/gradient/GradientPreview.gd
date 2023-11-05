class_name GradientPreview extends TextureRect

const MIN_SIZE := Vector2i(200, 200)

var shader_linear := preload(
	"res://src/Shaders/Gradients/Linear.gdshader")
var shader_linear_dither := preload(
	"res://src/Shaders/Gradients/LinearDithering.gdshader")

var shader := shader_linear

var preview_rect := Rect2i()


@onready var trans_checker := $TransChecker


func _ready():
	custom_minimum_size = MIN_SIZE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var sm := ShaderMaterial.new()
	sm.shader = shader
	material = sm
	

func render(img :Image):
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

	texture = ImageTexture.create_from_image(img)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	queue_redraw()


func update_material(params:Dictionary):
	for param in params:
		material.set_shader_parameter(param, params[param])
