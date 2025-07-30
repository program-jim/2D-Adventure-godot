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

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact() -> void:
	super()
	
	animation_player.play("activated")
	Game.save_data()
