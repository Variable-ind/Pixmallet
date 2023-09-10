extends HFlowContainer

class_name ColorSwitch


# use as template. duplicated is becuase children might be deleted.
@onready var switch_btn_tmpl:ColorRect = $ColorSwitchBtn.duplicate()



func _ready():
	switch_btn_tmpl.hide()


func set_colors(colors: PackedColorArray):
	clear()
			
	for c in colors:
		var _b = switch_btn_tmpl.duplicate()
		_b.color = c
		_b.show()
		add_child(_b)


func clear():
	for cb in get_children():
		cb.queue_free()

