extends Panel

class_name ColorPalette

@onready var colorForeground :ColorPickerButton = %Foreground
@onready var colorBackground :ColorPickerButton = %Background


func _ready():
	set_color_picker(colorForeground.get_picker())
	set_color_picker(colorBackground.get_picker())
	
	
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
