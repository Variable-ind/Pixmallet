extends Panel

class_name ColorPalette

const PALETTE_ROW_NUM = 12
	
var current_palette : ColorPaletteRes
var palettes_stack :Array[ColorPaletteRes] = []

@onready var colorForeground :ColorPickerButton = %Foreground
@onready var colorBackground :ColorPickerButton = %Background
@onready var paletteSelector :MenuButton = %PaletteSelector
@onready var colorSwitch :ColorSwitch = %ColorSwitch


func _ready():
	set_color_picker(colorForeground.get_picker())
	set_color_picker(colorBackground.get_picker())
	
	# palettes
	load_palettes()


func load_palettes():
	# ensure default palette
	if not ResourceLoader.exists(config.PATH_PALETTE_DEFAULT):
		var default_palette = ColorPaletteRes.new()
		default_palette.set_to_default()
		ResourceSaver.save(default_palette, config.PATH_PALETTE_DEFAULT)
		print('create palette: ', config.PATH_PALETTE_DEFAULT)
	
	var palette_dir :DirAccess = g.user_palette_dir
	var files = palette_dir.get_files()
	
	for file in files:
		var _res = ResourceLoader.load(
			config.PATH_PALETTE_DIR.path_join(file))
		palettes_stack.append(_res)

	var popmenu = paletteSelector.get_popup()
	for pal in palettes_stack:
		popmenu.add_radio_check_item(pal.name)
	
	switch_palette(0)
	
	
func switch_palette(index:int=0):
	current_palette = palettes_stack[index]
	paletteSelector.text = current_palette.name
	colorSwitch.set_colors(current_palette.colors)
	var popmenu = paletteSelector.get_popup()
	popmenu.set_item_checked(index, true)


func create_palette(palette_name):
	var new_palette :ColorPaletteRes = ColorPaletteRes.new()
	palettes_stack.append(new_palette)
	var popmenu = paletteSelector.get_popup()
	popmenu.add_radio_check_item(new_palette.name)
	switch_palette(palettes_stack.size()-1)
	ResourceSaver.save(new_palette, config.PATH_PALETTE_DIR)


func set_color_picker(picker):
	picker.can_add_swatches = false
	picker.color_mode = ColorPicker.MODE_RGB
	picker.color_modes_visible = true
	picker.deferred_mode = true
	picker.hex_visible = true
	picker.picker_shape = ColorPicker.SHAPE_HSV_RECTANGLE
	picker.presets_visible = false
	picker.sampler_visible = true
	picker.sliders_visible = true


func _on_switch_color():
	var tmp_color :Color = colorForeground.color
	colorForeground.color = colorBackground.color
	colorBackground.color = tmp_color
