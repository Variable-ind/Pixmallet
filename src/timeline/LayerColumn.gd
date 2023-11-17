class_name LayerColumn extends VBoxContainer

var layers :Array[BaseLayer] = []

var selected_layer_bars :Array[LayerBar] = []
var layer_bars :Array[LayerBar] = []

@onready var layer_bar :LayerBar = $LayerBar


func attach(proj_layers:Array[BaseLayer]):
	for ly in proj_layers:
		var new_layer := layer_bar.duplicate()
		new_layer.attach(ly)
		layers.append(new_layer)


func _get_drag_data(pos: Vector2):
#	if layers_column.get_global_rect()
#	var box := HBoxContainer.new()
#	for sel_layer in selected_layers:
#		box.add_child(sel_layer)
#	set_drag_preview(box)

	return selected_layer_bars


func _can_drop_data(pos: Vector2, _data) -> bool:
	return true


func _drop_data(pos: Vector2, data) -> void:
	print(pos, data)

