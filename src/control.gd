extends Control

@onready var artboard = %Artboard
@onready var overlay = $overlay


func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 700))
	
	var project = Project.new(Vector2i(400, 300))
	artboard.load_project(project)

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
