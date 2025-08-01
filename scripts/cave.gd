####################
#
#	File Name: cave.gd
#	File Created Date: July 31 2025
#	Language: GDScript
#	File Description:
#		Extend script of cave on world.gd
#
####################

extends World


func _on_boar_died() -> void:
	await get_tree().create_timer(1).timeout
	Game.change_scene("res://scenes/game_end_screen.tscn", {
		duration = 1,
	})
	
