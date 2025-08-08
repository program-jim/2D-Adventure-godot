####################
#
#	File Name: teleporter.gd
#	File Created Date: July 21 2025
#	Language: GDScript
#	File Description:
#		Teleporter behavior
#
####################

class_name Teleporter
extends Interactable

@export_file("*.tscn") var path: String
@export var entry_point: String

func interact() -> void:
	if entry_point:
		super()
		Game.change_scene(path, {"entry_point" = entry_point})
