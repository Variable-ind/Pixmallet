class_name BaseDrawer extends RefCounted

signal drawing_started(drawer)
signal drawing_stopped()

var color_op := ColorOp.new()

var is_drawing := false

var size := Vector2i.ONE

var alpha := 1.0 :
	set(val):
		alpha = clampf(val, 0.0, 1.0)
		color_op.strength = alpha


class ColorOp:
	var strength := 1.0


func can_draw(_pos :Vector2i):
	pass


func reset():
	pass


func draw_start(_pos: Vector2i):
	is_drawing = true
	drawing_started.emit(self)


func draw_move(pos: Vector2i):
	# This can happen if the user switches between tools with a shortcut
	# while using another tool
	if !is_drawing:
		draw_start(pos)


func draw_end(_pos: Vector2i):
	is_drawing = false
	drawing_stopped.emit()

