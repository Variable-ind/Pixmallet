extends HFlowContainer

class_name ColorSwitches

signal add_color_switch
signal remove_color_switch(index)
signal select_color_switch(index)

const TOTAL_LIMIT = 60

const TOOLTIP_TEXT_TMPL = '({r},{g},{b},{a})\n#{hex}\n\nRight click to remove'

var current_color :Color = Color.BLACK :
	set(color):
		current_color = color
		queue_redraw()

@onready var addSwitchBtn:Button = $AddSwitchBtn


#func _ready():
#	print(current_color)


func append_color_switch(color: Color):
	var color_rect = ColorRect.new()
	color_rect.color = color
	color_rect.focus_mode = Control.FOCUS_NONE
	color_rect.custom_minimum_size = addSwitchBtn.get_minimum_size()
	color_rect.size_flags_horizontal = Control.SIZE_FILL
	color_rect.size_flags_vertical = Control.SIZE_FILL
	color_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	color_rect.gui_input.connect(_on_switch_btn_pressed.bind(color_rect))
	color_rect.tooltip_text = TOOLTIP_TEXT_TMPL.format({
		'r': color.r8, 'g': color.g8, 'b': color.b8, 'a': color.a8, 'hex': color.to_html()})
	add_child(color_rect)
#	addSwitchBtn.add_sibling(color_rect)  # DO NOT do that way, complex color index matching.


func set_switches(colors: PackedColorArray):
	clear_switches()
	if colors.size() >= TOTAL_LIMIT:
		colors = colors.slice(0, TOTAL_LIMIT - 1)
		addSwitchBtn.hide()

	for c in colors:
		append_color_switch(c)
		
	move_child(addSwitchBtn, get_child_count() -1)  # move add button after switches.



func clear_switches():
	for cb in get_children():
		if cb is ColorRect:
			cb.queue_free()


func find_switch(switch):
	for cb in get_children():
		if cb == switch and cb is ColorRect:
			return cb


func _draw():
	for cb in get_children():
		if cb is ColorRect and cb.color == current_color:
			draw_rect(Rect2(cb.position, cb.size + Vector2(1,1)), 
			 		  Color.WHITE, false, 1)


func _on_add_switch_btn_pressed():
	add_color_switch.emit()


func _on_switch_btn_pressed(event, event_target):
	if event is InputEventMouseButton and event.pressed:
		var index = event_target.get_index()
		# The add button is after all switches, that's why only need get_index().
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				select_color_switch.emit(index)
			MOUSE_BUTTON_RIGHT:
				remove_color_switch.emit(index)
