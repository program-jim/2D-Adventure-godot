####################
#
#	File Name: game.gd
#	File Created Date: July 21 2025
#	Language: GDScript
#	File Description:
#		Global manager of whole game.
#
####################

extends CanvasLayer

# Mind Map of world_states
# scene_name => {
#	enemies_alive => [enemies_path]
#}
var world_states := {}

@onready var player_stats: Node = $PlayerStats
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color.a = 0
	

func change_scene(path: String, entry_point: String) -> void:
	var tree := get_tree()
	tree.paused = true
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1, 0.2)
	await tween.finished
	
	var old_name := tree.current_scene.scene_file_path.get_file().get_basename()
	world_states[old_name] = tree.current_scene.to_dict()
	
	
	tree.change_scene_to_file(path)
	await tree.process_frame # before ENGINE VER 4.2
	await tree.process_frame # before ENGINE VER 4.2
#	await tree.tree_changed # since ENGINE VER 4.2

	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			tree.current_scene.update_player(node.global_position, node.direction)
			break
			
	tree.paused = false
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0, 0.2)
