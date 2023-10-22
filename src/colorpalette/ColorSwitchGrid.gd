class_name ColorSwitchGrid extends GridContainer

signal add_color_switch
signal select_color_switch(index)
signal remove_color_switch(index)
signal move_color_switch(index, to_index)


const TOTAL_LIMIT = 120


var current_color :Color = Color.BLACK :
	set(color):
		# allow to multiple switch with same color been selected at same time.
		current_color = color
		for switch in get_switches():
			switch.selected = switch.color == color

@onready var addSwitchBtn:Button = $AddSwitchBtn


func _ready():
	addSwitchBtn.pressed.connect(_on_add_switch_btn_pressed)
	

func get_switches() -> Array:
	var switches = []
	for child in get_children():
		if child is ColorSwitch:
			switches.append(child)
	return switches


func append_color_switch(color: Color, index):
	var color_switch = ColorSwitch.new()
	color_switch.color = color
	color_switch.switch_index = index
	color_switch.custom_minimum_size = addSwitchBtn.custom_minimum_size
	color_switch.gui_input.connect(_on_switch_input.bind(index))
	add_child(color_switch)
#	addSwitchBtn.add_sibling(color_rect)  # DO NOT do that way, complex color index matching.


func set_switches(colors: PackedColorArray, color:Color):
	clear_switches()
	
	if colors.size() >= TOTAL_LIMIT:
		colors = colors.slice(0, TOTAL_LIMIT - 1)
		addSwitchBtn.hide()

	for i in colors.size():
		# append color switch matches with index of colors list.
		append_color_switch(colors[i], i)
		
	move_child(addSwitchBtn, get_child_count() -1)
	# move add button after switches.
	
	# to hit current switch, 
	# must change current_color after switch is appended.
	current_color = color


func clear_switches():
	for cb in get_children():
		if cb is ColorSwitch:
			cb.queue_free()

func find_switch_by_pos(pos):
	for switch in get_switches():
		var _rect = Rect2(switch.position, switch.size) 
		if _rect.has_point(pos):
			return switch 
	return null


func _get_drag_data(at_position:Vector2):
	var drag_switch = find_switch_by_pos(at_position)
	if not drag_switch:
		return
	var drag: ColorRect = ColorRect.new()
	drag.size = drag_switch.size
	drag.color = drag_switch.color
	set_drag_preview(drag)
	return drag_switch


func _can_drop_data(_position, _data):
	return true


func _drop_data(at_position:Vector2, data):
	var drop_switch = find_switch_by_pos(at_position)
	if not drop_switch:
		return
	move_color_switch.emit(data.switch_index, drop_switch.switch_index)


func _on_add_switch_btn_pressed():
	add_color_switch.emit()


func _on_switch_input(event, switch_index):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				select_color_switch.emit(switch_index)
			MOUSE_BUTTON_RIGHT:
				remove_color_switch.emit(switch_index)


func _on_switch_removed(index):
	remove_color_switch.emit(index)
