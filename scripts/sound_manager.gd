extends Node

@export var is_all_sfx_play: bool = true
@export var is_all_bgm_play: bool = true

@onready var sfx: Node = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func play_sfx(name: String) -> void:
	if not is_all_sfx_play:
		return
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		print("Audio SFX [" + name + "] NOT FOUND !!!")
		return
	else:
		player.play()
		
		
func play_bgm(stream: AudioStream) -> void:
	if not is_all_bgm_play:
		return
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.play()	
		

func setup_ui_sounds(node: Node) -> void:
	var button := node as Button
	if button:
		button.pressed.connect(play_sfx.bind("UIPress"))
		button.focus_entered.connect(play_sfx.bind("UIFocus"))
		
		
func setup_ui_sounds_with_all_children(node: Node) -> void:
	setup_ui_sounds(node)
	
	for child in node.get_children():
		setup_ui_sounds_with_all_children(child)


#func setup_sound(sound_name: String) -> void:
	#pass
