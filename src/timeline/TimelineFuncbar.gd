class_name TimelineFuncbar extends HBoxContainer

var project :Project

@onready var optbtn_add := $OptBtnAdd
@onready var btn_delete := $BtnDelete
@onready var btn_up := $BtnUp
@onready var btn_down := $BtnDown
@onready var btn_clone := $BtnClone
@onready var btn_merge := $BtnMerge
@onready var btn_add_frame := $BtnAddFrame
@onready var btn_remove_frame := $BtnRemoveFrame
@onready var btn_clone_frame := $BtnCloneFrame
@onready var btn_tag := $BtnTag
@onready var btn_play_reverse := $BtnPlayReverse
@onready var btn_play := $BtnPlay
@onready var btn_loop := $BtnLoop
@onready var btn_onion_setting := $BtnOnionSetting
@onready var btn_onion := $BtnOnion
@onready var opt_fps := $OptFPS


func _ready():
	optbtn_add.item_selected.connect(_on_add_selected)


func attach(proj:Project):
	project = proj


func _on_add_selected(index):
	match index:
		0: add_layer()
		1: add_group()
		

func add_layer():
	if not project:
		return
	project.add_layer()
	

func add_group():
	if not project:
		return
	project.add_group()


