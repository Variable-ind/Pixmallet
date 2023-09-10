extends Node

var control:Control
var viewport: SubViewportContainer

var camera:Camera2D

var user_palette_dir: DirAccess

@onready var projects :Array = []
@onready var current_project = Rect2(Vector2.ZERO, Vector2(650, 650))


func _ready():
	ensure_dirs()
	
	
func ensure_dirs():
	
	# palette dirs
	if not DirAccess.dir_exists_absolute(config.PATH_PALETTE_DIR):
			var err = DirAccess.make_dir_recursive_absolute(
				config.PATH_PALETTE_DIR)
			if err != OK:
				notification(NOTIFICATION_CRASH)
	user_palette_dir = DirAccess.open(config.PATH_PALETTE_DIR)
	if not user_palette_dir:
		notification(NOTIFICATION_CRASH)
		printerr(DirAccess.get_open_error())
	
