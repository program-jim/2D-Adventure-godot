extends AnimatedSprite2D

const STICK_DEAD_ZONE := 0.5
const MOUSE_DEAD_ZONE := 16.0


func _ready() -> void:
	DisplayServer.is_touchscreen_available()
	
	if Input.get_connected_joypads():
		show_joypad_icon(0)
	else:
		play("keyboard")


func _input(event: InputEvent) -> void:
	if (
		event is InputEventJoypadButton or
		(event is InputEventJoypadMotion and abs(event.axis_value) > STICK_DEAD_ZONE)
	):
		show_joypad_icon(event.device)

	if (
		event is InputEventKey or
		event is InputEventMouseButton or
		(event is InputEventMouseMotion and event.velocity.length() > MOUSE_DEAD_ZONE)
	):
		play("keyboard")


func show_joypad_icon(device: int = 0) -> void:
	var joypad_name := Input.get_joy_name(device)

	if "Nintendo" in joypad_name:
		play("nintendo")
	elif "Dualshock" in joypad_name or "PS" in joypad_name:
		play("playstation") # Playstation
	else:
		play("xbox") # Xbox
