extends HBoxContainer

class_name LayerFuncbar


var ico_unlock: Texture2D = preload("res://assets/icons/unlock.png")
var ico_locked: Texture2D = preload("res://assets/icons/locked.png")
var ico_eye_open: Texture2D = preload("res://assets/icons/eye-open.png")
var ico_eye_close: Texture2D = preload("res://assets/icons/eye-close.png")
var ico_unlink: Texture2D = preload("res://assets/icons/unlink.png")
var ico_linked: Texture2D = preload("res://assets/icons/linked.png")

@onready var btn_visiable :Button = $BtnVisiable
@onready var btn_lock :Button = $BtnLock
@onready var btn_link :Button = $BtnLink


func _ready():
	for	btn in get_children():
		if btn is Button:
			btn.pressed.connect(_on_pressed.bind(btn))


func _on_pressed(btn):
	pass
