class_name PropBucket extends VBoxContainer

var operator :Variant

@onready var similarity := $Similarity
@onready var opt_contiguous := $OptContiguous


func subscribe(new_operator:Bucket):
	unsubscribe()
	operator = new_operator
	similarity.value = operator.similarity  # max/min defined in operator.
	opt_contiguous.value = operator.opt_contiguous
	
	similarity.value_changed.connect(_on_similarity_changed)
	opt_contiguous.toggled.connect(_on_contiguous_toggled)


func unsubscribe():
	if similarity.value_changed.is_connected(_on_similarity_changed):
		similarity.value_changed.disconnect(_on_similarity_changed)
	if opt_contiguous.toggled.is_connected(_on_contiguous_toggled):
		opt_contiguous.toggled.disconnect(_on_contiguous_toggled)
	operator = null


func _on_similarity_changed(value):
	operator.similarity = value


func _on_contiguous_toggled(btn_pressed):
	operator.opt_contiguous = btn_pressed
