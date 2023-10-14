class_name ColorSwitch extends ColorRect

const TOOLTIP_TMPL = 'RGBa: ({r},{g},{b},{a})\nHEX: #{hex}\n\nRight click to remove'

var selected :bool = false :
	set(val):
		selected = bool(val)
		queue_redraw()


var switch_index:int = -1 # give when add_child, matched with colors list.
	

func _init():
	focus_mode = Control.FOCUS_NONE
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_FILL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = TOOLTIP_TMPL.format({
		'r': color.r8, 'g': color.g8, 'b': color.b8, 'a': color.a8,
		'hex': color.to_html()
	})
	
	# The ColorRect-nodes will "steal" the input if they overlap with 
	# the Control-node if the default mouse_filter is used. 
	# Set it to "Pass" or "Ignore".
	mouse_filter = Control.MOUSE_FILTER_PASS


func _draw():
	if selected:
		var outline_rect := Rect2(Vector2.ONE, size - Vector2.ONE)
		var outline_color := Color.WHITE
		draw_rect(outline_rect.grow(-1), outline_color.inverted(), false, 1)
		draw_rect(outline_rect, outline_color, false, 1)
