extends Control

@onready var control = $"."
@onready var viewport: SubViewportContainer = control.find_child("DrawContainer")

@onready var camera = viewport.find_child("Camera2D")

@onready var v_ruler = %VRuler
@onready var overlay = $overlay


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 700))
	g.control = control
	g.viewport = viewport
	g.camera = camera
	
	# update rulers
#	viewport.item_rect_changed.connect(v_ruler.queue_redraw)
#	project_changed.connect(v_ruler.queue_redraw)

	# ensure modal background overlay is hide
	overlay.hide()


func _on_navigation_to(navId, data):
	print(navId, data)
	match navId:
		Navbar.NEW_FILE:
			pass
		Navbar.OPEN_FILE:
			pass


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
