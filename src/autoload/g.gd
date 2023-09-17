extends Node

var control:Control
var viewport: SubViewportContainer

var camera:Camera2D

var keyChain :KeyChain = KeyChain.new()

@onready var projects :Array = []
@onready var current_project = Rect2(Vector2.ZERO, Vector2(650, 650))
	

func _ready():
	keyChain.single_event_mode = true
	print('KeyChian is loaded.')
