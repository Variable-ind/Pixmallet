extends Control

var camera :CanvasCamera
var canvas :Canvas

var foreground_color := Color.WHITE
var background_color := Color.BLACK

@onready var artboard := %Artboard
@onready var overlay := %overlay
@onready var navbar := %Navbar
@onready var toolbar := %Toolbar
@onready var colorPalette := %ColorPalette


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 700))
	
	var project = Project.new(Vector2i(400, 300))
	artboard.load_project(project)
	camera = artboard.camera
	canvas = artboard.canvas
	
	navbar.launch()
	colorPalette.launch(foreground_color, background_color)
	
	# ensure modal background overlay is hide
	overlay.hide()


func _on_navbar_navigation_to(nav_id, data):
	match nav_id:
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
			artboard.show_mouse_guide = data.get('checked')
		Navbar.SHOW_SYMMETRY_GRID:
			if data.get('checked'):
				artboard.show_symmetry_guide_state = SymmetryGuide.CROSS_AXIS
			else:
				artboard.show_symmetry_guide_state = SymmetryGuide.NONE
		Navbar.SHOW_RULERS:
			artboard.show_rulers = data.get('checked')


func _on_toolbar_activated(operate_id):
	match operate_id:
		Operate.MOVE:
			artboard.state = Operate.MOVE
		Operate.PAN:
			artboard.state = Operate.PAN
		Operate.ZOOM:
			artboard.state = Operate.ZOOM
		Operate.PENCIL:
			artboard.state = Operate.PENCIL
			artboard.set_current_color(foreground_color)
		Operate.BRUSH:
			artboard.state = Operate.BRUSH
			artboard.set_current_color(foreground_color)
		Operate.ERASE:
			artboard.state = Operate.ERASE
		Operate.SHADING:
			artboard.state = Operate.SHADING
		Operate.CROP:
			artboard.state = Operate.CROP
		Operate.COLORPICK:
			artboard.state = Operate.COLORPICK
		Operate.BUCKET:
			artboard.state = Operate.BUCKET
			artboard.set_current_color(foreground_color)
		Operate.SELECT_RECTANGLE:
			artboard.state = Operate.SELECT_RECTANGLE
		Operate.SELECT_ELLIPSE:
			artboard.state = Operate.SELECT_ELLIPSE
		Operate.SELECT_POLYGON:
			artboard.state = Operate.SELECT_POLYGON
		Operate.SELECT_LASSO:
			artboard.state = Operate.SELECT_LASSO
		Operate.SELECT_MAGIC:
			artboard.state = Operate.SELECT_MAGIC
		Operate.SHAPE_RECTANGLE:
			artboard.state = Operate.SHAPE_RECTANGLE
			artboard.set_current_color(foreground_color)
		Operate.SHAPE_ELLIPSE:
			artboard.state = Operate.SHAPE_ELLIPSE
			artboard.set_current_color(foreground_color)
		Operate.SHAPE_POLYGON:
			artboard.state = Operate.SHAPE_POLYGON
			artboard.set_current_color(foreground_color)
		Operate.SHAPE_LINE:
			artboard.state = Operate.SHAPE_LINE
			artboard.set_current_color(foreground_color)
		_:
			pass


func _on_active_adjust_tool(adjustId):
	print(adjustId)
	


func _on_modal_toggled(state:bool):
	if overlay:
		overlay.visible = state


func _on_color_palette_color_changed(color_foreground, color_background):
	foreground_color = color_foreground
	background_color = color_background
	artboard.set_current_color(foreground_color)

