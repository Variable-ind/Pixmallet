extends Control

var camera :CanvasCamera
var canvas :Canvas

var current_color :Color

@onready var artboard := %Artboard
@onready var overlay := $overlay


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 700))
	
	var project = Project.new(Vector2i(400, 300))
	artboard.load_project(project)
	camera = artboard.camera
	canvas = artboard.canvas
	
	# ensure modal background overlay is hide
	overlay.hide()


func _on_navigation_to(navId, data):
	match navId:
		Navbar.NEW_FILE:
			pass
		Navbar.OPEN_FILE:
			pass
		
		Navbar.ZOOM_IN:
			camera.zoom_in()
		Navbar.ZOOM_OUT:
			camera.zoom_out()
		
		Navbar.SHOW_CARTESIAN_GRID:
			artboard.show_cartesian_grid = data.get('checked')
		Navbar.SHOW_ISOMETRIC_GRID:
			artboard.show_isometric_grid = data.get('checked')
		Navbar.SHOW_PIX_GRID:
			artboard.show_pixel_grid = data.get('checked')
		Navbar.SHOW_GUIDES:
			artboard.show_guides = data.get('checked')
		Navbar.SHOW_MOUSE_GUIDES:
			artboard.show_mouse_guides = data.get('checked')
		Navbar.SHOW_SYMMETRY_GRID:
			if data.get('checked'):
				artboard.show_symmetry_guide_state = SymmetryGuide.CROSS_AXIS
			else:
				artboard.show_symmetry_guide_state = SymmetryGuide.NONE
		Navbar.SHOW_RULERS:
			artboard.show_rulers = data.get('checked')


func _on_active_tool(toolId):
	print(toolId)
	match toolId:
		Toolbar.COLOR_PICKER:
			pass


func _on_active_adjust_tool(adjustId):
	print(adjustId)
	


func _on_modal_toggled(state:bool):
	if overlay:
		overlay.visible = state


func _on_color_palette_color_changed(color):
	current_color = color
