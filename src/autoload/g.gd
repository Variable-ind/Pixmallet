extends Node

var control:Control
var viewport: SubViewportContainer

var camera:Camera2D

@onready var projects :Array = []
@onready var current_project = Rect2(Vector2.ZERO, Vector2(650, 650))
