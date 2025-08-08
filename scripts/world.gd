####################
#
#	File Name: world.gd
#	File Created Date: July 6 2025
#	Language: GDScript
#	File Description:
#		The behavior of World root.
#
####################

class_name World
extends Node2D

@export var bgm: AudioStream
@export var is_bgm_play : bool = true

@onready var tile_map: TileMap = $TileMap
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	var used := tile_map.get_used_rect().grow(-1)
	var tile_size := tile_map.tile_set.tile_size
	
	print("used: " + str(used))
	print("tile_size: " + str(tile_size))
	
	camera_2d.limit_top = used.position.y * tile_size.y
	print("camera_2d.limit_top: " + str(camera_2d.limit_top))
	
	camera_2d.limit_right = used.end.x * tile_size.x
	print("camera_2d.limit_right: " + str(camera_2d.limit_right))
	
	camera_2d.limit_bottom = used.end.y * tile_size.y
	print("camera_2d.limit_bottom: " + str(camera_2d.limit_bottom))
	
	camera_2d.limit_left = used.position.x * tile_size.x
	print("camera_2d.limit_left: " + str(camera_2d.limit_left))
	
	camera_2d.reset_smoothing()
	print("camera_2d.reset_smoothing()")

	if bgm and is_bgm_play:
		SoundManager.play_bgm(bgm)
	

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#Game.back_to_title()
		#print("data saved")
	
	
func update_player(pos: Vector2, direction: Player.Direction) -> void:
	player.global_position = pos
	player.fall_from_y = pos.y
	player.direction = direction
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll() # since 4.2


func to_dict() -> Dictionary:
	var enemies_alive := []
	for node in get_tree().get_nodes_in_group(Game.ENEMIES_TAG):
		var path := get_path_to(node) as String
		enemies_alive.append(path)
		print("ENEMY PATH: " + path)
	
	return {
		"enemies_alive" = enemies_alive,
	}


func from_dict(dict: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group(Game.ENEMIES_TAG):
		var path := get_path_to(node) as String
		#if node not in dict["enemies_alive"]:
			#print(str(node))
			#node.queue_free()

