####################
#
#	File Name: hitbox.gd
#	File Created Date: July 13 2025
#	Language: GDScript
#	File Description:
#		Hitbox function for all objects can attack.
#
####################

## Shit
class_name Hitbox
extends Area2D

signal hit(hurtbox)

func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurtbox: Hurtbox) -> void:
	#print("[Hit] %s => %s" % [owner.name, hurtbox.owner.name])
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
	
