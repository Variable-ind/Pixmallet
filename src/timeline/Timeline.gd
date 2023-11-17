class_name Timeline extends VBoxContainer

var project:Project

var layers :Array = []
var frames :Array[BaseCel] = []

@onready var layer_bar :LayerBar = %LayerBar


func load_project(proj:Project):
	pass
