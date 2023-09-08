extends Control


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
