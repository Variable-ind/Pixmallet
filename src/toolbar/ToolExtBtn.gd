extends Button

const LONG_PRESS_DELAY = 0.6
var long_press_timer = Timer.new()
@onready var popup:PopupPanel = $Popup


func _ready():
	add_child(long_press_timer)
	long_press_timer.one_shot = true
	long_press_timer.wait_time = LONG_PRESS_DELAY
	long_press_timer.timeout.connect(show_popup)
	


func _on_button_down():
	if long_press_timer.is_stopped():
		long_press_timer.start()


func _on_button_up():
	if not long_press_timer.is_stopped():
		long_press_timer.stop()


func show_popup():
	popup.position = global_position + Vector2(32, -3)
	popup.show()
