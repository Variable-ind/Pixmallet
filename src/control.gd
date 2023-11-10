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
@onready var adjustment := %Adjustment
@onready var properties := %Properties

@onready var dialog_crop := %CropDialog
@onready var dialog_gradient := %GradientDialog

@onready var dialog_img_crop := %ImgCropDialog
@onready var dialog_img_offset := %ImgOffsetDialog
@onready var dialog_img_scale := %ImgScaleDialog
@onready var dialog_img_flip := %ImgFlipDialog
@onready var dialog_img_rotate := %ImgRotateDialog
@onready var dialog_img_outline := %ImgOutlineDialog
@onready var dialog_img_shadow := %ImgShadowDialog
@onready var dialog_img_invert := %ImgInvertDialog
@onready var dialog_img_desaturation := %ImgDesaturationDialog
@onready var dialog_img_hsv := %ImgHSVDialog
@onready var dialog_img_posterize := %ImgPosterizeDialog


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 700))

	g.current_project = Project.new(Vector2i(400, 300))
	
	artboard.load_project(g.current_project)
	preview.load_project(g.current_project)
	
	camera = artboard.camera
	canvas = artboard.canvas
	
	
	navbar.launch()
	
	# color
	colorPalette.path_palette_dir = config.PATH_PALETTE_DIR
	colorPalette.launch(foreground_color, background_color)
	artboard.set_current_color(foreground_color)
	
	# properties
	properties.propPencil.subscribe(canvas.drawer_pencil)
	properties.propBrush.subscribe(canvas.drawer_brush)
	properties.propEraser.subscribe(canvas.drawer_eraser)
	properties.propShading.subscribe(canvas.drawer_shading)
	properties.propBucket.subscribe(canvas.bucket)
	properties.propZoom.subscribe(camera)
	properties.propCrop.subscribe(canvas.crop_sizer)
	properties.propMove.subscribe(canvas.move_sizer)
	properties.propColorpick.subscribe(canvas.color_pick)
	properties.propShape.subscribe(canvas.silhouette)
	properties.propSelection.subscribe(canvas.selection)
	
	# ensure modal background overlay is hide
	overlay.hide()


func _on_navbar_navigation_to(nav_id, data):
	match nav_id:
		Navbar.NEW_FILE:
			pass
		Navbar.OPEN_FILE:
			pass
		
		Navbar.UNDO:
			history.undo()
		Navbar.REDO:
			history.redo()
		
		Navbar.SELECT_ALL:
			canvas.select_all()
		Navbar.CLEAR_SEL:
			canvas.select_deselect()
		Navbar.INVERT_SEL:
			canvas.select_invert()
		
		Navbar.ZOOM_IN:
			camera.zoom_in()
		Navbar.ZOOM_OUT:
			camera.zoom_out()
		
		Navbar.FILL_FOREGROUND:
			canvas.fill_color(foreground_color)
		Navbar.FILL_BACKGROUND:
			canvas.fill_color(background_color)
		
		Navbar.CROP_CANVAS:
			dialog_crop.launch(g.current_project)
		
		Navbar.IMG_CROP:
			dialog_img_crop.launch(g.current_project)
		Navbar.IMG_OFFSET:
			dialog_img_offset.launch(g.current_project)
		Navbar.IMG_SCALE:
			dialog_img_scale.launch(g.current_project)
		Navbar.IMG_FLIP:
			dialog_img_flip.launch(g.current_project)
		Navbar.IMG_ROTATE:
			dialog_img_rotate.launch(g.current_project)
		Navbar.IMG_OUTLINE:
			dialog_img_outline.launch(g.current_project,
									  foreground_color)
		Navbar.IMG_DROP_SHADOW:
			dialog_img_shadow.launch(g.current_project)
		Navbar.IMG_INVERT_COLOR:
			dialog_img_invert.launch(g.current_project)
		Navbar.IMG_DESATURATION:
			dialog_img_desaturation.launch(g.current_project)
		Navbar.IMG_HSV:
			dialog_img_hsv.launch(g.current_project)
		Navbar.IMG_POSTERIZE:
			dialog_img_posterize.launch(g.current_project)
		Navbar.GRADIENT:
			dialog_gradient.launch(g.current_project,
								   artboard.canvas.selection)

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
			canvas.snapper.snap_to_grid_center = data.get('checked')
		Navbar.SNAP_GRID_BOUNDARY:
			canvas.snapper.snap_to_grid_boundary = data.get('checked')
		Navbar.SNAP_SYMMETRY_GRID:
			canvas.snapper.snap_to_symmetry_guide = data.get('checked')
		Navbar.SNAP_GUIDES:
			canvas.snapper.snap_to_guide = data.get('checked')
		
		Navbar.SUPPORT:
			OS.shell_open(config.URL_SUPPORT)
		Navbar.LOG_FOLDER:
			OS.shell_open(ProjectSettings.globalize_path(config.PATH_LOGS))


func _on_toolbar_activated(operate_id):
	artboard.state = operate_id
	properties.state = operate_id


func _on_adjusted(adjust_id):
	match adjust_id:
		AdjustmentTool.FLIP_H:
			canvas.flip_x()
		AdjustmentTool.FLIP_V:
			canvas.flip_y()
		AdjustmentTool.ROTATE_CCW:
			canvas.rotate_ccw()
		AdjustmentTool.ROTATE_CW:
			canvas.rotate_cw()


func refresh_canvas():
	canvas.refresh()


func _on_modal_toggled(state :bool):
	overlay.visible = state


func _on_color_palette_color_changed(color_foreground :Color,
									 color_background :Color):
	foreground_color = color_foreground
	background_color = color_background
	artboard.set_current_color(foreground_color)


func _on_artboard_color_picked(color :Color):
	colorPalette.set_color(color)
