class_name Pivot extends RefCounted

enum {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	MIDDLE_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_CENTER,
	BOTTOM_LEFT,
	MIDDLE_LEFT,
	CENTER,
}


static func get_pivot_offset(pivot, to_size:Vector2i) -> Vector2i:
	var _offset = Vector2i.ZERO
	match pivot:
		TOP_LEFT:
			pass
			
		TOP_CENTER:
			_offset.x = to_size.x / 2.0

		TOP_RIGHT:
			_offset.x = to_size.x

		MIDDLE_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y / 2.0

		BOTTOM_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y

		BOTTOM_CENTER:
			_offset.x = to_size.x / 2.0
			_offset.y = to_size.y

		BOTTOM_LEFT:
			_offset.y = to_size.y

		MIDDLE_LEFT:
			_offset.y = to_size.y / 2.0
		
		CENTER:
			_offset.x = to_size.x / 2.0
			_offset.y = to_size.y / 2.0
			
	return _offset
	
