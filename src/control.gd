extends Control

var camera :CanvasCamera
var canvas :Canvas

var foreground_color := Color.WHITE
var background_color := Color.BLACK

@onready var artboard := %Artboard
@onready var preview := %Preview
@onready var overlay := %overlay
@onready var navbar := %Navbar
@onready var toolbar := %Toolbar
@onready var colorPalette := %ColorPalette
@onready var properties := %Properties


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 700))
	
	var project = Project.new(Vector2i(400, 300))
	artboard.load_project(project)
	preview.load_project(project)
	
	camera = artboard.camera
	canvas = artboard.canvas
	
	navbar.launch()
	
	# color
	colorPalette.path_palette_dir = config.PATH_PALETTE_DIR
	colorPalette.launch(foreground_color, background_color)
	artboard.set_current_color(foreground_color)
	
	# properties
	properties.propPencil.subscribe(artboard.canvas.drawer_pencil)
	properties.propBrush.subscribe(artboard.canvas.drawer_brush)
	properties.propEraser.subscribe(artboard.canvas.drawer_eraser)
	properties.propShading.subscribe(artboard.canvas.drawer_shading)
	properties.propBucket.subscribe(artboard.canvas.bucket)
	properties.propZoom.subscribe(artboard.camera)
	properties.propCrop.subscribe(artboard.canvas.crop_sizer)
	properties.propMove.subscribe(artboard.canvas.move_sizer)
	properties.propColorpick.subscribe(artboard.canvas.color_pick)
	properties.propShape.subscribe(artboard.canvas.silhouette)
	properties.propSelection.subscribe(artboard.canvas.selection)
	
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
		
		Navbar.FILL_FOREGROUND:
			artboard.canvas.fill_color(foreground_color)
		Navbar.FILL_BACKGROUND:
			artboard.canvas.fill_color(background_color)
		
		Navbar.CROP_CANVAS:
			toolbar.choose_toolbtn('Crop')

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
			
		Navbar.SNAP_GRID_CENTER:
			artboard.canvas.snapper.snap_to_grid_center = data.get('checked')
		Navbar.SNAP_GRID_BOUNDARY:
			artboard.canvas.snapper.snap_to_grid_boundary = data.get('checked')
		Navbar.SNAP_SYMMETRY_GRID:
			artboard.canvas.snapper.snap_to_symmetry_guide = data.get('checked')
		Navbar.SNAP_GUIDES:
			artboard.canvas.snapper.snap_to_guide = data.get('checked')
		
		Navbar.SUPPORT:
			OS.shell_open(config.URL_SUPPORT)
		Navbar.LOG_FOLDER:
			OS.shell_open(ProjectSettings.globalize_path(config.PATH_LOGS))


func _on_toolbar_activated(operate_id):
	artboard.state = operate_id
	properties.state = operate_id


func _on_active_adjust_tool(adjust_id):
	print(adjust_id)


func _on_modal_toggled(state :bool):
	overlay.visible = state


func _on_color_palette_color_changed(color_foreground :Color,
									 color_background :Color):
	foreground_color = color_foreground
	background_color = color_background
	artboard.set_current_color(foreground_color)



func _on_artboard_color_picked(color :Color):
	colorPalette.set_color(color)
