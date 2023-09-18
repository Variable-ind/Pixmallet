
extends Button

class_name LayerFuncButton

signal layer_property_changed

enum BtnType {
	VISIBLE,
	LOCK,
	LINK,
}

@export var btn_type = BtnType
@export var triggered = false

@export var ico_on: Texture2D
@export var ico_off: Texture2D


func _ready():
	if triggered:
		icon = ico_on
	else:
		icon = ico_off
		
	if not Engine.is_editor_hint(): 
		pressed.connect(_on_pressed)


func _on_pressed():
	if triggered:
		triggered = false
		icon = ico_off
	else:
		triggered = true
		icon = ico_on
	
	layer_property_changed.emit(btn_type, triggered, BtnType)
