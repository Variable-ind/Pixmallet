class_name Properties extends Panel

var state := Operate.NONE :
	set = set_state
var property_panels := []

@onready var propPencil := %Pencil
@onready var propBrush := %Brush
@onready var propEraser := %Eraser

@onready var propShape := %Shape
@onready var propZoom := %Zoom
@onready var propCrop := %Crop
@onready var propBucket := %Bucket
@onready var propSelection := %Selection
@onready var propShading := %Shading
@onready var propMove := %Move
@onready var propPan := %Pan
@onready var propColorpick := %Colorpick


func _ready():
	property_panels.append(propPencil)
	property_panels.append(propEraser)
	property_panels.append(propBrush)
	property_panels.append(propShape)
	property_panels.append(propZoom)
	property_panels.append(propCrop)
	property_panels.append(propBucket)
	property_panels.append(propSelection)
	property_panels.append(propShading)
	property_panels.append(propMove)
	property_panels.append(propPan)
	property_panels.append(propColorpick)
	
	for prop in property_panels:
		prop.visible = false


func set_state(val):
	if state != val:
		state = val
		for prop in property_panels:
			prop.visible = false
		
		if state in [Operate.SHAPE_RECTANGLE, Operate.SHAPE_ELLIPSE,
					 Operate.SHAPE_LINE, Operate.SHAPE_POLYGON]:
			propShape.visible = true
			propShape.set_for_polygon(state == Operate.SHAPE_POLYGON)

		elif state in [Operate.SELECT_RECTANGLE, Operate.SELECT_ELLIPSE,
					   Operate.SELECT_POLYGON, Operate.SELECT_LASSO,
					   Operate.SELECT_MAGIC]:
			propSelection.visible = true
			
		elif state == Operate.PENCIL:
			propPencil.visible = true
		
		elif state == Operate.ERASE:
			propEraser.visible = true
		
		elif state == Operate.BRUSH:
			propBrush.visible = true
		
		elif state == Operate.BUCKET:
			propBucket.visible = true
		
		elif state == Operate.CROP:
			propCrop.visible = true
		
		elif state == Operate.ZOOM:
			propZoom.visible = true
		
		elif state == Operate.SHADING:
			propShading.visible = true
		
		elif state == Operate.MOVE:
			propMove.visible = true
		
		elif state == Operate.PAN:
			propPan.visible = true
		
		elif state == Operate.COLORPICK:
			propColorpick.visible = true

