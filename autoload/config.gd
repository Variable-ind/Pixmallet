class_name Config extends Node

const PATH_LOGS = 'user://logs'
const PATH_PROFILE = 'user://profile'
const PATH_PALETTE_DIR = 'user://palettes/'

const URL_SUPPORT = 'https://support'


func _ready():
	ensure_dirs([
		PATH_PALETTE_DIR,
		PATH_LOGS,
	])


func ensure_dirs(dir_paths :Array[String]):
	for path in dir_paths:
		if not DirAccess.dir_exists_absolute(path):
			var err = DirAccess.make_dir_recursive_absolute(path)
			if err != OK:
				printerr(err)
				
