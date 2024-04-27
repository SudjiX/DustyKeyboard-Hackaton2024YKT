extends CharacterBody2D

class_name Player

signal health_changed (new_health)

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

enum {
	IDLE,
	MOVE,
	ATTACK1,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	JUMP,
	DAMAGE,
	DEATH,
	LOSE}


const SPEED = 120.0
const JUMP_VELOCITY = -300.0
var max_health = 100
var health
var money = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_pos
var damage_basic = 10
var damage_multiplayer = 1
var damage_current

#Гравитация
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Signals.connect("enemy_attack", Callable (self, "_on_damage_received"))
	health = max_health

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y > 0:
		animation_player.play("Fall")
		
	damage_current = damage_basic * damage_multiplayer
		
	match state:
		MOVE:
			move_state()
		ATTACK1:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		JUMP:
			jump_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
		LOSE:
			lose_state()
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)

func death_state():
	animation_player.play("Death")
	await animation_player.animation_finished
	state = LOSE
	
func lose_state ():
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")

func move_state ():
	var direction = Input.get_axis("Move_Left", "Move_Right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animation_player.play("Walk")
			else:
				animation_player.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animation_player.play("Idle")
	if direction == -1:
		animated_sprite_2d.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		animated_sprite_2d.flip_h = false
		$AttackDirection.rotation_degrees = 0
	if Input.is_action_pressed("Run"):
		run_speed = 1
	else:
		run_speed = 1

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		state = JUMP
	
	if Input.is_action_pressed("Block"):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE
	if Input.is_action_just_pressed("Attack") and attack_cooldown == false:
		state = ATTACK1

func jump_state ():
	velocity.y = JUMP_VELOCITY
	animation_player.play("Jump")
	state = MOVE

func block_state ():
	velocity.x = 0
	animation_player.play("Block")
	if Input.is_action_just_released("Block"):
		state = MOVE

func slide_state ():
	animation_player.play("Slide")
	run_speed = 0
	await animation_player.animation_finished
	state = MOVE

func attack_state ():
	damage_multiplayer = 1
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = ATTACK2
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animation_player.play("Attack1")
	await animation_player.animation_finished
	#attack_freeze ()
	state = MOVE

func attack2_state (): 
	damage_multiplayer = 1.2
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = ATTACK3
	animation_player.play("Attack2")
	await animation_player.animation_finished
	state = MOVE

func attack3_state ():
	damage_multiplayer = 2
	animation_player.play("Attack3")
	await animation_player.animation_finished
	state = MOVE

func combo1 ():
	combo = true
	await animation_player.animation_finished
	combo = false


func damage_state ():
	velocity.x = 0
	animation_player.play("Damage")
	await animation_player.animation_finished
	state = MOVE

func _on_damage_received (enemy_damage):
	if state == BLOCK:
		enemy_damage /= 2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
		health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH
	emit_signal("health_changed", health)
	print(health)
	
func _on_hit_box_area_entered(_area):
	Signals.emit_signal("player_attack", damage_current)
