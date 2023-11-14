class_name Clipboard extends RefCounted

static var image := Image.new()
static var image_pos := Vector2i.ZERO
static var text := ''

static func has_image():
	return not image.is_empty()
	

static func set_image(img:Image, pos:=Vector2i.ZERO):
	image.copy_from(img)
	image_pos = pos


static func get_image() ->Image:
	return image


static func get_image_posistion() -> Vector2i:
	return image_pos


static func has_text() -> bool:
	return text.length() > 0
		

static func set_text(txt:String):
	text = txt
	

static func get_text() ->String:
	return text
	
