extends Button

class_name ExtendableButton
# THIS CLASS MIGHT USE FOR MULTIPLE TOOLBAR BUTTONS.

const CELL_WIDTH :int = 36
const LONG_PRESS_DELAY :float = 0.6
var long_press_timer :Timer = Timer.new()
var arrow_icon_color :Color = Color(1, 1, 1, 0.66)
var sel_name: StringName = ''

@onready var popup :PopupPanel = $Popup
@onready var extend_btns = $Popup/ExtendBtns.get_children()



func _ready():
	add_child(long_press_timer)
	long_press_timer.one_shot = true
	long_press_timer.wait_time = LONG_PRESS_DELAY
	long_press_timer.timeout.connect(show_popup)
	
	var erase_list: Array = []
	for btn in extend_btns:
		if btn is Button:
			btn.pressed.connect(_on_select_extend_btn.bind(btn))
		else:
			erase_list.append(btn)
	
	for er in erase_list:
		extend_btns.erase(er)
		
	# set current btn
	change_btn(extend_btns[0].name, extend_btns[0].icon)
	
	# set popup
	popup.size = Vector2(CELL_WIDTH * extend_btns.size(), CELL_WIDTH)
	popup.hide()
	print(size.x)
	
	queue_redraw()


func _draw():
	# draw arrow
	draw_colored_polygon([Vector2(36, 16), Vector2(32, 12), Vector2(32, 20)],
						 arrow_icon_color)


func get_selected_btn():
	for btn in extend_btns:
		if btn.name == name:
			return btn


func change_btn(btn_name:StringName, btn_icon:Texture2D):
	sel_name = btn_name
	icon = btn_icon


func show_popup():
	popup.position = global_position + Vector2(36, -3)
	popup.show()


func _on_button_down():
	if long_press_timer.is_stopped():
		long_press_timer.start()


func _on_button_up():
	if not long_press_timer.is_stopped():
		long_press_timer.stop()


func _on_select_extend_btn(btn):
	change_btn(btn.name, btn.icon)
	popup.hide()
	await get_tree().create_timer(0.1).timeout
	pressed.emit()
	# toogle mode button must switch `Action Mode` to `Button Press`
	# to prevent mouse up outside switch to pressed style but not really pressed.
