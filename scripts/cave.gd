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


func _on_boar_died(id_go: String) -> void:
	if id_go == "8A998A37-2FF3-EC65-02B7-FA583D4C58D0":
		await get_tree().create_timer(1)
		Game.change_scene("res://scenes/game_end_screen.tscn", {
			duration = 1,
		})
