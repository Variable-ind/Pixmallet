class_name Timeline extends VBoxContainer

var project:Project

var layers :Array = []
var frames :Array[BaseCel] = []


var selected_frames :Array[FrameBtn] = []
var selected_cels :Array[CelBtn] = []

@onready var layer_tree :LayerTree = %LayerTree


func load_project(proj:Project):
	project = proj
	
	layer_tree.attach(project.layers)
