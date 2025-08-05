####################
#
#	File Name: player.gd
#	File Created Date: July 6 2025
#	Language: GDScript
#	File Description:
#		The main controller of Player.
#
####################

class_name Player
extends CharacterBody2D

enum Direction{
	LEFT = -1,
	RIGHT = 1
}

enum State{
	IDLE,
	RUN,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
	WALL_JUMP,
	ATTACK_01,
	ATTACK_02,
	ATTACK_03,
	HURT,
	DIE,
	SLIDING_START,
	SLIDING_LOOP,
	SLIDING_END,
}

const GROUND_STATES := [
	State.IDLE, State.RUN, State.LANDING,
	State.ATTACK_01, State.ATTACK_02, State.ATTACK_03,
]
const RUN_SPEED := 160.0
const JUMP_VELOCITY := -425.0
const FLOOR_ACCELERATION := RUN_SPEED / 0.2
const AIR_ACCELERATION := RUN_SPEED / 0.1
const WALL_JUMP_VELOCITY := Vector2(400, -280)
const KNOCKBACK_AMOUT := 512.0
const SLIDING_DURATION := 0.3
const SLIDING_SPEED := 256.0
const SLIDING_ENERGY := 4.0
const LANDING_HEIGHT := 100.0

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false
var pending_damage : Damage
var fall_from_y : float
var interacting_with : Array[Interactable]

#@export var is_coyote_global: bool = false
@export var original_pos := Vector2(142, 82)
@export var can_combo := false
@export var alpha_lose := 50
@export var direction := Direction.RIGHT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var hand_checker: RayCast2D = $Graphics/HandChecker
@onready var foot_checker: RayCast2D = $Graphics/FootChecker
@onready var state_machine: Node = $StateMachine
@onready var stats: Node = Game.player_stats
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var slide_request_timer: Timer = $SlideRequestTimer
@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon
@onready var game_over_screen: Control = $CanvasLayer/GameOverScreen
@onready var attack_audio: AudioStreamPlayer = $Audio/AttackAudio
@onready var jump_audio: AudioStreamPlayer = $Audio/JumpAudio
@onready var pause_screen: Control = $CanvasLayer/PauseScreen

func _ready() -> void:
	stand(default_gravity, 0.01)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUMP_VELOCITY * 0.5:
			velocity.y = JUMP_VELOCITY * 0.5
			
	if event.is_action_pressed("attack") and can_combo:
		is_combo_requested = true
		
	if event.is_action_pressed("slide"):
		slide_request_timer.start()
		
	if event.is_action_pressed("interact") and interacting_with:
		interacting_with.back().interact()

	if event.is_action_pressed("pause_game"):
		pause_screen.show_pause()


func tick_physics(state: State, delta: float) -> void:
	interaction_icon.visible = not interacting_with.is_empty()
	
	if invincible_timer.time_left > 0:
		var alpha_lose_percent := 1 / alpha_lose
		graphics.modulate.a = sin(Time.get_ticks_msec() * alpha_lose_percent) * 0.5 + 0.5
	else:
		graphics.modulate.a = 1
	
	match state:
		State.IDLE:
			move(default_gravity, delta)
			
		State.RUN:
			move(default_gravity, delta)
			
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity, delta)
			
		State.FALL:
			move(default_gravity, delta)
			
		State.LANDING:
			stand(default_gravity, delta)
			
		State.WALL_SLIDING:
			move(default_gravity / 3, delta)
			direction = Direction.RIGHT if get_wall_normal().x > 0 else Direction.LEFT
			#direction = Direction.LEFT if get_wall_normal().x > 0 else Direction.RIGHT
			

		State.WALL_JUMP:
			if state_machine.state_time < 0.1:
				stand(0.0 if is_first_tick else default_gravity, delta)
				direction = Direction.RIGHT if get_wall_normal().x > 0 else Direction.LEFT
				#direction = Direction.LEFT if get_wall_normal().x > 0 else Direction.RIGHT
			else:
				move(default_gravity, delta)
				
		State.ATTACK_01, State.ATTACK_02, State.ATTACK_03:
			stand(default_gravity, delta)
			
		State.HURT, State.DIE:
			stand(default_gravity, delta)
			
		State.SLIDING_END:
			stand(default_gravity, delta)
			
		State.SLIDING_START, State.SLIDING_LOOP:
			slide(delta)
		
	is_first_tick = false
			
			
func move(gravity: float, delta: float) -> void:
	var movement := Input.get_axis("move_left", "move_right")
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	
	velocity.x = move_toward(velocity.x, movement * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta
		
	if not is_zero_approx(movement):
		direction = Direction.LEFT if movement < 0 else Direction.RIGHT
		#print(str(sprite_2d.flip_h))
	
	#print(str(movement))
	move_and_slide()
	#coyote(is_coyote_global, was_on_floor, should_jump)
	

func stand(gravity: float, delta: float) -> void:
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.y += gravity * delta
	
	move_and_slide()
	
	
func slide(delta: float) -> void:
	velocity.x = direction * SLIDING_SPEED
	velocity.y += default_gravity * delta
	
	move_and_slide()
	
	
func die() -> void:
	game_over_screen.show_game_over()
	
	#get_tree().reload_current_scene()
	#stats.health = stats.max_health


func register_interactable(v: Interactable) -> void:
	if state_machine.current_state == State.DIE:
		return
	if v in interacting_with:
		return
	else:
		interacting_with.append(v)


func unregister_interactable(v: Interactable) -> void:
	interacting_with.erase(v)


func can_wall_slide() -> bool:
	return is_on_wall() and hand_checker.is_colliding() and foot_checker.is_colliding()
	
	
func should_slide() -> bool:
	if slide_request_timer.is_stopped():
		return false
	if stats.energy < SLIDING_ENERGY:
		return false 
	return not foot_checker.is_colliding()
	
	
## DEPRECATED
#func coyote(is_coyote: bool, was_on_floor: bool, should_jump: bool) -> void:
#	if is_coyote:		
#		if is_on_floor() != was_on_floor:
#			if was_on_floor and not should_jump:
#				coyote_timer.start()
#			else:
#				coyote_timer.stop()
				

func get_next_state(state: State) -> int:
	if stats.health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DIE else State.DIE
		
	if pending_damage:
		return State.HURT
	
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	
	if state in GROUND_STATES and not is_on_floor():
		return State.FALL
	
	var movement := Input.get_axis("move_left", "move_right")
	var is_still := is_zero_approx(movement) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_01
			if should_slide():
				return State.SLIDING_START
			if not is_still:
				return State.RUN		
			
		State.RUN:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_01
			if should_slide():
				return State.SLIDING_START
			if is_still:
				return State.IDLE
			
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
			
		State.FALL:
			if is_on_floor():
				var height := global_position.y - fall_from_y
				return State.LANDING if height >= LANDING_HEIGHT else State.RUN
			if can_wall_slide():
				return State.WALL_SLIDING
				
		State.LANDING:
#			if not is_still:
#				return State.RUN
			if not animation_player.is_playing():
				return State.IDLE
				
		State.WALL_SLIDING:
			if jump_request_timer.time_left > 0 and not is_first_tick:
				return State.WALL_JUMP
			if is_on_floor():
				return State.IDLE
			if not is_on_wall():
				return State.FALL
				
		State.WALL_JUMP:
			if can_wall_slide() and not is_first_tick:
				return State.WALL_SLIDING
			if velocity.y >= 0:
				return State.FALL
				
		State.ATTACK_01:
			if not animation_player.is_playing():
				return State.ATTACK_02 if is_combo_requested else State.IDLE
			
		State.ATTACK_02:
			if not animation_player.is_playing():
				return State.ATTACK_03 if is_combo_requested else State.IDLE
			
		State.ATTACK_03, State.HURT:
			if not animation_player.is_playing():
				return State.IDLE
				
		State.SLIDING_START:
			if not animation_player.is_playing():
				return State.SLIDING_LOOP
				
		State.SLIDING_LOOP:
			if state_machine.state_time > SLIDING_DURATION or is_on_wall():
				return State.SLIDING_END
				
		State.SLIDING_END:
			if not animation_player.is_playing():
				return State.IDLE

	return StateMachine.KEEP_CURRENT


func transition_state(from: State, to: State) -> void:
	print("[%s] PLAYER_STATE: %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "<START>",
		State.keys()[to]
	])
	
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()

	match to:
		State.IDLE:
			animation_player.play("idle")
		
		State.RUN:
			animation_player.play("run")

		State.JUMP:
			animation_player.play("jump")
			
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()

			SoundManager.play_sfx("Jump")
			#jump_audio.play()

		State.FALL:
			animation_player.play("fall")

			if from in GROUND_STATES:
				coyote_timer.start()
			fall_from_y = global_position.y
				
		State.LANDING:
			animation_player.play("landing")

		State.WALL_SLIDING:
			animation_player.play("wall_sliding")

		State.WALL_JUMP:
			animation_player.play("jump")
			
			velocity = WALL_JUMP_VELOCITY
			velocity.x *= get_wall_normal().x
			jump_request_timer.stop()

		State.ATTACK_01:
			animation_player.play("attack_01")
			is_combo_requested = false
			SoundManager.play_sfx("Attack")
			#attack_audio.play()

		State.ATTACK_02:
			animation_player.play("attack_02")
			is_combo_requested = false

		State.ATTACK_03:
			animation_player.play("attack_03")
			is_combo_requested = false

		State.HURT:
			animation_player.play("hurt")
			Input.start_joy_vibration(0, 0, 1, 0.5)

			stats.health -= pending_damage.amount
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUT

			pending_damage = null
			invincible_timer.start()

		State.DIE:
			animation_player.play("die")
			invincible_timer.stop()
			interacting_with.clear()

		State.SLIDING_START:
			animation_player.play("sliding_start")
			slide_request_timer.stop()
			stats.energy -= SLIDING_ENERGY

		State.SLIDING_LOOP:
			animation_player.play("sliding_loop")

		State.SLIDING_END:
			animation_player.play("sliding_end")

	#if to == State.WALL_JUMP:
		#Engine.time_scale = 0.3
		#print("time slower.")
	#if from == State.WALL_JUMP:
		#Engine.time_scale = 1.0
		#print("time back to 1.")
	
	is_first_tick = true


func _on_hurtbox_hurt(hitbox) -> void:
#	stats.health -= 1
#	if stats.health == 0:
#		queue_free()

	if invincible_timer.time_left > 0:
		return

	# TODO: May cause order error.
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
	
