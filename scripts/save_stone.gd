####################
#
#	File Name: save_stone.gd
#	File Created Date: July 29 2025
#	Language: GDScript
#	File Description:
#		Save stone behavior.
#
####################


extends Interactable

@export var is_audio_play: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact() -> void:
	super()
	
	animation_player.play("activated")
	if is_audio_play:	
		SoundManager.play_sfx("SaveStone")
	Game.save_data()
