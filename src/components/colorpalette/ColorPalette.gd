class_name ColorPalette extends Panel

signal modal_toggled(state:int)
signal color_changed(color_foreground, color_background)

const PALETTE_ROW_NUM = 12

var current_palette : ColorPaletteRes
var palettes_stack :Array[ColorPaletteRes] = []
var current_palette_index: int = -1

var keymap := {
	'FlipColor': {
		'action': 'flip_color', 
		'event': KeyChain.makeEventKey(KEY_X)
	},
}

@onready var colorForeground :ColorPickerButton = %Foreground
@onready var colorBackground :ColorPickerButton = %Background
@onready var colorSwitchBtn :Button = %ColorSwitchBtn
@onready var paletteSelector :MenuButton = %PaletteSelector
@onready var colorSwitchGrid :ColorSwitchGrid = %ColorSwitchGrid
@onready var createDialog :Window = $CreateDialog
@onready var deleteDialog :Window = $DeleteDialog

@onready var createPaletteBtn :Button = %CreatePaletteBtn
@onready var removePaletteBtn :Button = %RemovePaletteBtn


func _ready():
	createDialog.hide()
	deleteDialog.hide()
	createDialog.visibility_changed.connect(
		_on_dialog_toggled.bind(createDialog))
	deleteDialog.visibility_changed.connect(
		_on_dialog_toggled.bind(deleteDialog))
	
	set_color_picker(colorForeground.get_picker())
	set_color_picker(colorBackground.get_picker())
	var stylebox = colorForeground.get_theme_stylebox('pressed').duplicate()
	colorForeground.add_theme_stylebox_override('normal', stylebox)
	
	colorForeground.color_changed.connect(_on_foreground_color_changed)
	colorBackground.color_changed.connect(_on_background_color_changed)
	colorSwitchBtn.pressed.connect(_on_switch_color)
	
	# set shortcuts X.
	colorSwitchBtn.shortcut = Shortcut.new()
	var event := InputEventAction.new()
	event.action = 'flip_color'
	colorSwitchBtn.shortcut.events.append(event)
	var action = g.keyChain.add_action(event.action, 
									   colorSwitchBtn.name, 
									   name)
	action.bind_event(KeyChain.makeEventKey(KEY_X))
	
	# palettes
	load_palettes()
	
	# signal handlers
	createDialog.confirmed.connect(_on_create_dialog_confirmed)
	deleteDialog.confirmed.connect(_on_delete_dialog_confirmed)
	
	createPaletteBtn.pressed.connect(_on_create_palette_btn_pressed)
	removePaletteBtn.pressed.connect(_on_del_palette_btn_pressed)
	
	colorSwitchGrid.add_color_switch.connect(_on_add_color_switch)
	colorSwitchGrid.move_color_switch.connect(_on_move_color_switch)
	colorSwitchGrid.remove_color_switch.connect(_on_remove_color_switch)
	colorSwitchGrid.select_color_switch.connect(_on_select_color_switch)


func launch(foreground_color :Color, background_color :Color):
	colorForeground.color = foreground_color
	colorBackground.color = background_color
	colorSwitchGrid.current_color = colorForeground.color


func load_palettes():
	# ensure default palette
	var default_palette_tres_file = config.PATH_PALETTE_DIR.path_join(
									ColorPaletteRes.DEFAULT_FILE)
	if not ResourceLoader.exists(default_palette_tres_file):
		var default_palette = ColorPaletteRes.new()
		default_palette.set_to_default()
		save_palette(default_palette)
		print('create palette: ', default_palette_tres_file)
	
	var palette_dir :DirAccess = DirAccess.open(config.PATH_PALETTE_DIR)
	var files = palette_dir.get_files()
	
	var default_res = null
	for file in files:
		var _res = ResourceLoader.load(
			config.PATH_PALETTE_DIR.path_join(file))
		if _res:
			if _res.as_default:
				default_res = _res
			else:
				palettes_stack.append(_res)
	
	if default_res:
		palettes_stack.insert(0, default_res)

	var popmenu = paletteSelector.get_popup()
	popmenu.index_pressed.connect(switch_palette)
	
	for pal in palettes_stack:
		popmenu.add_radio_check_item(pal.name)
	
	switch_palette(0)
	
	
func switch_palette(index:int=0):
	if index >= palettes_stack.size() or index < 0:
		return
	current_palette = palettes_stack[index]
	paletteSelector.text = current_palette.name
	colorSwitchGrid.set_switches(current_palette.colors, colorForeground.color)
	var popmenu = paletteSelector.get_popup()
	if current_palette_index >= 0:
		popmenu.set_item_checked(current_palette_index, false)
	popmenu.set_item_checked(index, true)
	current_palette_index = index
	
	removePaletteBtn.disabled = current_palette.as_default


func create_palette(palette_name:String):
	var new_palette :ColorPaletteRes = ColorPaletteRes.new(palette_name)
	palettes_stack.append(new_palette)
	save_palette(new_palette)
	var popmenu = paletteSelector.get_popup()
	popmenu.add_radio_check_item(new_palette.name)
	switch_palette(palettes_stack.size()-1)
	

func delete_palette(index:int=0):
	if index >= palettes_stack.size() or index < 0:
		return
	
	var rm_palette = palettes_stack[index]
	
	if rm_palette.as_default:
		return

	palettes_stack.remove_at(index)
	DirAccess.remove_absolute(
		config.PATH_PALETTE_DIR.path_join(rm_palette.file))
	
	var popmenu = paletteSelector.get_popup()
	popmenu.remove_item(index)
	if current_palette_index == index:
		current_palette_index = -1
	switch_palette(palettes_stack.size()-1)


func save_palette(palette:ColorPaletteRes):
	if palette.as_default and palette.colors.size() <= 0:
		palette.set_to_default()
		colorSwitchGrid.set_switches(palette.colors, colorForeground.color)
	ResourceSaver.save(palette,
					   config.PATH_PALETTE_DIR.path_join(palette.file))	


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
	colorSwitchGrid.current_color = colorForeground.color
	color_changed.emit(colorForeground.color, colorBackground.color)


func _on_create_dialog_confirmed(new_palette_name):
	create_palette(new_palette_name)


func _on_delete_dialog_confirmed():
	delete_palette(current_palette_index)


func _on_create_palette_btn_pressed():
	createDialog.show()


func _on_del_palette_btn_pressed():
	deleteDialog.show()
	deleteDialog.set_hint(current_palette.name)
		

func _on_dialog_toggled(dialog):
	modal_toggled.emit(dialog.visible)


func _on_add_color_switch():
	current_palette.colors.append(colorForeground.color)
	colorSwitchGrid.set_switches(current_palette.colors, colorForeground.color)
	save_palette(current_palette)


func _on_remove_color_switch(index):
	current_palette.colors.remove_at(index)
	colorSwitchGrid.set_switches(current_palette.colors, colorForeground.color)
	save_palette(current_palette)


func _on_move_color_switch(index, to_index):
	var color = current_palette.colors[index]
	current_palette.colors.remove_at(index)
	current_palette.colors.insert(to_index, color)
	colorSwitchGrid.set_switches(current_palette.colors, colorForeground.color)
	save_palette(current_palette)


func _on_select_color_switch(index):
	colorForeground.color = current_palette.colors[index]
	colorSwitchGrid.current_color = colorForeground.color
	color_changed.emit(colorForeground.color, colorBackground.color)


func _on_foreground_color_changed(color):
	colorSwitchGrid.current_color = color
	color_changed.emit(color, colorBackground.color)


func _on_background_color_changed(color):
	color_changed.emit(colorForeground.color, color)
	
