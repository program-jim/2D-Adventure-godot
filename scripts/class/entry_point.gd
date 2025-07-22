####################
#
#	File Name: entry_point.gd
#	File Created Date: July 21 2025
#	Language: GDScript
#	File Description:
#		entry point controller
#
####################

class_name EntryPoint
extends Marker2D

@export var direction := Player.Direction.RIGHT

func _ready() -> void:
	add_to_group("entry_points")
