extends Control

@onready var control = $"."
@onready var viewport: SubViewportContainer = control.find_child("DrawContainer")

@onready var camera = viewport.find_child("Camera2D")

@onready var v_ruler = %VRuler


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 600))
	g.control = control
	g.viewport = viewport
	g.camera = camera
	
	# update rulers
#	viewport.item_rect_changed.connect(v_ruler.queue_redraw)
#	project_changed.connect(v_ruler.queue_redraw)


func _on_navbar_navigation_to(navId, data):
	print(navId, data)
	match navId:
		Navbar.NEW_FILE:
			pass
		Navbar.OPEN_FILE:
			pass


func _on_toolbar_active_tool(toolId):
	print(toolId)
	match toolId:
		Toolbar.COLOR_PICKER:
			pass
