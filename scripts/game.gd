####################
#
#	File Name: game.gd
#	File Created Date: July 21 2025
#	Language: GDScript
#	File Description:
#		Global manager of whole game.
#
####################

extends Node

@onready var player_stats: Node = $PlayerStats

func change_scene(path: String, entry_point: String) -> void:
	var tree := get_tree()
	tree.change_scene_to_file(path)
	await tree.process_frame # before ENGINE VER 4.2
	await tree.process_frame # before ENGINE VER 4.2
#	await tree.tree_changed # since ENGINE VER 4.2

	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			tree.current_scene.update_player(node.global_position, node.direction)
			break
