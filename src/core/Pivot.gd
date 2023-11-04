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
			_offset.x = round(to_size.x / 2.0)

		TOP_RIGHT:
			_offset.x = to_size.x

		MIDDLE_RIGHT:
			_offset.x = to_size.x
			_offset.y = round(to_size.y / 2.0)

		BOTTOM_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y

		BOTTOM_CENTER:
			_offset.x = round(to_size.x / 2.0)
			_offset.y = to_size.y

		BOTTOM_LEFT:
			_offset.y = to_size.y

		MIDDLE_LEFT:
			_offset.y = round(to_size.y / 2.0)
		
		CENTER:
			_offset.x = round(to_size.x / 2.0)
			_offset.y = round(to_size.y / 2.0)
			
	return _offset
	

static func get_position_offset(pivot, 
							   org_size:Vector2i,
							   to_size:Vector2i) -> Vector2i:
	# DONT DO THIS, when size is very small the result is incorerect.
	# because the int/float precision.
#	var _offset := Pivot.get_pivot_offset(pivot, to_size)
#	var coef :Vector2 = Vector2(_offset) / Vector2(to_size)
#	var size_diff :Vector2 = Vector2(org_rect.size - to_size) * coef
#	var dest_pos :Vector2i = Vector2(org_rect.position) + size_diff

	var _pos = Vector2i.ZERO
	var delta_w := (org_size.x - to_size.x)
	var delta_h := (org_size.y - to_size.y)
	
	match pivot:
		TOP_LEFT:
			pass
			
		TOP_CENTER:
			_pos.x += round(delta_w / 2.0)

		TOP_RIGHT:
			_pos.x += delta_w

		MIDDLE_RIGHT:
			_pos.x += delta_w
			_pos.y += round(delta_h / 2.0)

		BOTTOM_RIGHT:
			_pos.x += delta_w
			_pos.y += delta_h

		BOTTOM_CENTER:
			_pos.x += round(delta_w / 2.0)
			_pos.y = delta_h

		BOTTOM_LEFT:
			_pos.y = delta_h

		MIDDLE_LEFT:
			_pos.y = round(delta_h / 2.0)
		
		CENTER:
			_pos.x = round(delta_w / 2.0)
			_pos.y = round(delta_h / 2.0)
			
	return _pos
	
