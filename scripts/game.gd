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

const SAVE_PATH := "user://data.sav"

@export var is_pretty_json : bool = false

@onready var player_stats: Node = $PlayerStats
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color.a = 0
	

func change_scene(path: String, params := {}) -> void:
	var tree := get_tree()
	tree.paused = true
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1, 0.2)
	await tween.finished
	
	var old_name := tree.current_scene.scene_file_path.get_file().get_basename()
	world_states[old_name] = tree.current_scene.to_dict()
	
	tree.change_scene_to_file(path)
	
	if "init" in params:
		params.init.call()
	
	#await tree.process_frame # before ENGINE VER 4.2
#	await tree.process_frame # before ENGINE VER 4.2
	await tree.tree_changed # since ENGINE VER 4.2

	var new_name := tree.current_scene.scene_file_path.get_file().get_basename()
	if new_name in world_states:
		tree.current_scene.from_dict(world_states[new_name])

	if "entry_point" in params:
		for node in tree.get_nodes_in_group("entry_points"):
			if node.name == params.entry_point:
				tree.current_scene.update_player(node.global_position, node.direction)
				break
				
	if "position" in params and "direction" in params:
		tree.current_scene.update_player(params.position, params.direction)
			
	tree.paused = false
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0, 0.2)
	
	
func save_data() -> void:
	var scene := get_tree().current_scene
	var scene_name := scene.scene_file_path.get_file().get_basename()
	world_states[scene_name] = scene.to_dict()
		
	var data := {
		world_states = world_states,
		stats = player_stats.to_dict(),
		scene = scene.scene_file_path,
		player = {
			direction = scene.player.direction,
			position = 
			{
				x = scene.player.global_position.x,
				y = scene.player.global_position.y,
			},
		},
	}
	
	var json := JSON.stringify(data, "\t") if is_pretty_json else JSON.stringify(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("fail to create file to write, PATH: " + str(SAVE_PATH))
		return
	file.store_string(json)
	print("Success to save data into a file !!!")
	
	
func load_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("fail to load file to read, PATH: " + str(SAVE_PATH))
		return
	
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary
	
	change_scene(data.scene, {
		direction = data.player.direction,
		position = Vector2(
			data.player.position.x,
			data.player.position.y,
		),
		init = func ():
			world_states = data.world_states
			player_stats.from_dict(data.stats)
	})
	
	print("Success to load data from a file !!!")
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		save_data()
		print("data saved")
	if event.is_action_pressed("ui_page_up"):
		load_data()
		print("data loaded")
