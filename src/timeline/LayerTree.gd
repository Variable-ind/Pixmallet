class_name LayerTree extends VBoxContainer

var current_selected_layer :BaseLayer
var layers :Array[BaseLayer] = []

var selected_layer_bars :Dictionary = {}
var layer_bars :Array[LayerBar] = []

@onready var layer_bar_tmpl :LayerBar = $LayerBarTMPL
@onready var column := $column


func _ready():
	layer_bar_tmpl.hide()


func reset():
	current_selected_layer = null
	
	layers.clear()
	layer_bars.clear()
	selected_layer_bars.clear()
	
	for ly in column.get_children():
		column.remove_child(ly)
		ly.destroy()


func attach(proj_layers:Array[BaseLayer]):
	reset()
	layers = proj_layers
	for ly in layers:
		var new_layer := layer_bar_tmpl.duplicate()
		column.add_child(new_layer)
		new_layer.attach(ly)
		layer_bars.append(new_layer)


func find_layer_bar_by_pos(pos):
	for bar in layer_bars:
		var _rect = Rect2(bar.position, bar.size) 
		if _rect.has_point(pos):
			return bar
	return null

#
#func _gui_input(event):
#	if event is InputEventMouseButton and event.pressed:
#		var rel_pos :Vector2i = event.position - column.position
#		var sel_layer_bar = find_layer_bar_by_pos(rel_pos)
#		if not sel_layer_bar:
#			return
#		print(sel_layer_bar)
#		if selected_layer_bars.is_empty():
#			current_selected_layer = sel_layer_bar.layer
#			selected_layer_bars[sel_layer_bar.index] = sel_layer_bar
#
#		elif event.ctrl_pressed:
#			if selected_layer_bars.has(sel_layer_bar.index):
#				if sel_layer_bar.layer != current_selected_layer:
#					selected_layer_bars.erase(sel_layer_bar.index)
#			else:
#				selected_layer_bars[sel_layer_bar.index] = sel_layer_bar
#
#		queue_redraw()


#func _draw():
#	for idx in selected_layer_bars:
#		var bar :LayerBar = selected_layer_bars[idx]
#		var rect := Rect2i(column.position + bar.position, bar.size)
#		rect.grow(1)
#		draw_rect(rect, selected_color, false)


func _get_drag_data(pos: Vector2):
	var drag_bar = find_layer_bar_by_pos(pos)
	if not drag_bar or selected_layer_bars.is_empty():
		return
	var box := HBoxContainer.new()
	for idx in selected_layer_bars:
		box.add_child(selected_layer_bars[idx])
	set_drag_preview(box)

	return selected_layer_bars


func _can_drop_data(pos: Vector2, _data) -> bool:
	return true


func _drop_data(pos: Vector2, data) -> void:
	print(pos, data)

