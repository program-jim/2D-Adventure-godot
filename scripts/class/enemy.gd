####################
#
#	File Name: enemy.gd
#	File Created Date: July 11 2025
#	Language: GDScript
#	File Description:
#		The behavior (base class) of all Enemy objects.
#
####################

class_name Enemy
extends CharacterBody2D

enum Direction{
	LEFT = -1,
	RIGHT = 1
}

signal died(id_go: String)

@export var direction := Direction.LEFT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction
@export var max_speed : float = 180.0
@export var acceleration : float = 2000.0
@export var id: String

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine
@onready var stats: Node = $Stats

func _ready() -> void:
	add_to_group(Game.ENEMIES_TAG)	

func move(speed: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	velocity.y += default_gravity * delta
	
	move_and_slide()
	
	
func die() -> void:
	died.emit(id)
	queue_free()
