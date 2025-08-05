extends TouchScreenButton

var finger_index := -1

@onready var rest_pos := global_position


func _input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	if st:
		if st.pressed and finger_index == -1:
			var global_pos := st.position * get_canvas_transform()
			var local_pos := global_pos * get_global_transform() # to_local(global_pos)
			var rect := Rect2(Vector2.ZERO, texture_normal.get_size())
			
			if rect.has_point(local_pos):
				# Press down
				finger_index = st.index
		elif not st.pressed and st.index == finger_index:
			# Press released
			finger_index = -1
			global_position = rest_pos

	var sd := event as InputEventScreenDrag
	if sd and sd.index == finger_index:
		# Drag
		global_position = sd.position * get_canvas_transform()
		
