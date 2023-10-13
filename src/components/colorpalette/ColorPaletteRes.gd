class_name ColorPaletteRes extends Resource

const PLAETTE_FILE_NAME_TMPL = 'color-palette-{}-{}.tres'


@export var name = ''
@export var file = '':
	set(file_name): file = _gen_filename(file_name)
	get: return file
		
			
@export var colors :PackedColorArray = PackedColorArray([
	Color.BLACK, Color.hex(0x999999ff), Color.WHITE,
])

var as_default :bool :
	get: return file == DEFAULT_FILE

# create default resource if need. 
const DEFAULT_NAME = 'Default'
const DEFAULT_FILE = 'color-palette-default.tres'
var default_colors :PackedColorArray = PackedColorArray([
	Color.BLACK, Color.WHITE,
	Color.hex(0x111111ff), Color.hex(0x333333ff), Color.hex(0x666666ff), Color.hex(0x8888888ff),
	Color.hex(0xaaaaaaff), Color.hex(0xccccccff), Color.hex(0xeeeeeeff),
	
	
	Color.hex(0xF1453Dff),
	Color.hex(0xE62565ff),
	Color.hex(0x9B2FAEff),
	Color.hex(0x673FB4ff),
	Color.hex(0x4054B2ff),
	Color.hex(0x2B98F0ff),
	Color.hex(0x1EAAF1ff),
	Color.hex(0x1FBCD2ff),
	Color.hex(0x159588ff),
	Color.hex(0x50AE55ff),
	Color.hex(0x8CC152ff),
	Color.hex(0xCDDA49ff),
	Color.hex(0xFEE94Eff),
	Color.hex(0xFDC02Fff),
	Color.hex(0xFD9727ff),
	Color.hex(0xFC5830ff),
	Color.hex(0x785549ff),
	Color.hex(0x9E9E9Eff),
	Color.hex(0x617D8Aff),
])


func _init(palette_name :String = '', file_name :String = ''):
	if not file:
		file = file_name
	if not name:
		name = palette_name


func set_to_default():
	colors.clear()
	for color in default_colors:
		colors.append(color)
	name = DEFAULT_NAME
	file = DEFAULT_FILE


func append_color(color: Color):
	colors.append(color)
	
	
func remove_color_at(index:int):
	colors.remove_at(index)
	

func clear():
	colors = []


func _gen_filename(file_name:String=''):
	if file_name:
		if file_name.ends_with('.tres'):
			return file_name
		else:
			return file_name + '.tres'
	else:
		return PLAETTE_FILE_NAME_TMPL.format([
			randi_range(100000, 999999),
			Time.get_ticks_msec(),
		], "{}")
	
