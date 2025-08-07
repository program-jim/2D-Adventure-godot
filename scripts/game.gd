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

signal camera_shake(amount: float)

# Mind Map of world_states
# scene_name => {
#	enemies_alive => [enemies_path]
#}
var world_states := {}

const PLAYER_DATA_PATH := "user://player_data.sav"
const SETTINGS_DATA_PATH := "user://settings_data.ini"

@export var is_pretty_json : bool = false

@onready var player_stats: Stats = $PlayerStats
@onready var color_rect: ColorRect = $ColorRect
@onready var default_player_stats := player_stats.to_dict()

func _ready() -> void:
	color_rect.color.a = 0
	load_settings_data()


func new_game() -> void:
	change_scene("res://scenes/forest.tscn", {
		duration = 1,
		init = func ():
			world_states = {}
			player_stats.from_dict(default_player_stats)
	})
	
	
func load_game() -> void:
	load_data()


func change_scene(path: String, params := {}) -> void:
	var duration := params.get("duration", 0.2) as float
	
	var tree := get_tree()
	tree.paused = true
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1, duration)
	await tween.finished
	
	if tree.current_scene is World:
		var old_name := tree.current_scene.scene_file_path.get_file().get_basename()
		world_states[old_name] = tree.current_scene.to_dict()
	
	tree.change_scene_to_file(path)
	
	if "init" in params:
		params.init.call()
	
	#await tree.process_frame # before ENGINE VER 4.2
#	await tree.process_frame # before ENGINE VER 4.2
	await tree.tree_changed # since ENGINE VER 4.2
	
	if tree.current_scene is World:
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
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 0, duration)


func back_to_title() -> void:
	change_scene("res://scenes/title_screen.tscn", {
		duration = 1,
	})


func has_save() -> bool:
	return FileAccess.file_exists(PLAYER_DATA_PATH)


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
	var file := FileAccess.open(PLAYER_DATA_PATH, FileAccess.WRITE)
	if not file:
		print("fail to create file to write, PATH: " + str(PLAYER_DATA_PATH))
		return
	file.store_string(json)
	
	file.close()
	print("Success to save data into a file !!!")


func load_data() -> void:
	var file := FileAccess.open(PLAYER_DATA_PATH, FileAccess.READ)
	if not file:
		print("fail to load file to read, PATH: " + str(PLAYER_DATA_PATH))
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
	
	file.close()
	print("Success to load data from a file !!!")


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#save_data()
		#print("data saved")
	#if event.is_action_pressed("ui_page_up"):
		#load_data()
		#print("data loaded")


func save_settings_data() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master", SoundManager.get_volume(SoundManager.Audio_Bus.MASTER))
	config.set_value("audio", "sfx", SoundManager.get_volume(SoundManager.Audio_Bus.SFX))
	config.set_value("audio", "bgm", SoundManager.get_volume(SoundManager.Audio_Bus.BGM))

	config.save(SETTINGS_DATA_PATH)
	print("Success to save settings data.")


func load_settings_data() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_DATA_PATH)
	if not config:
		print("Fail to load settings data.")
		return

	SoundManager.set_volume(
		SoundManager.Audio_Bus.MASTER,
		config.get_value("audio", "master", 0.5)
	)
	
	SoundManager.set_volume(
		SoundManager.Audio_Bus.SFX,
		config.get_value("audio", "sfx", 1.0)
	)
	
	SoundManager.set_volume(
		SoundManager.Audio_Bus.BGM,
		config.get_value("audio", "bgm", 1.0)
	)

	print("Success to load settings data.")


func shake_camera(amount: float) -> void:
	camera_shake.emit(amount)
	Engine.time_scale = 0.01
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1
