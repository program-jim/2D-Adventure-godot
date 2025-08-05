####################
#
#	File Name: title_screen.gd
#	File Created Date: July 30 2025
#	Language: GDScript
#	File Description:
#		The behavior of Title Screen control.
#
####################

extends Control

@export var bgm: AudioStream
@export var is_bgm_play: bool = false

@onready var v: VBoxContainer = $V
@onready var new_game: Button = $V/NewGame
@onready var load_game: Button = $V/LoadGame

func _ready() -> void:
	load_game.disabled = not Game.has_save()
	new_game.grab_focus()

	SoundManager.setup_ui_sounds_with_all_children(self)
	if bgm and is_bgm_play:
		SoundManager.play_bgm(bgm)


func _on_new_game_pressed() -> void:
	print("Starting New Game")
	SoundManager.play_sfx("UIPress")
	Game.new_game()


func _on_load_game_pressed() -> void:
	print("Loading Previous Game")
	Game.load_game()


func _on_exit_game_pressed() -> void:
	print("Quitting Game")
	get_tree().quit()
