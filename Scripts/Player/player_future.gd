extends CharacterBody2D

class_name FuturePlayer

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

enum {
	IDLE,
	MOVE,
	ATTACK1,
	SLIDE,
	JUMP,
	DAMAGE,
	DEATH,
	LOSE}

const SPEED = 120.0
const JUMP_VELOCITY = -300.0
var health = 100
var money = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_pos

#Гравитация
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Signals.connect("enemy_attack", Callable (self, "on_damage_received"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y > 0:
		animation_player.play("Fall")
		
	match state:
		MOVE:
			move_state()
		ATTACK1:
			attack_state()
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
	elif direction == 1:
		animated_sprite_2d.flip_h = false
	if Input.is_action_pressed("Run"):
		run_speed = 1.5
	else:
		run_speed = 1

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		state = JUMP
	
	if Input.is_action_pressed("Block"):
		state = SLIDE
	if Input.is_action_just_pressed("Attack") and attack_cooldown == false:
		state = ATTACK1

func jump_state ():
	velocity.y = JUMP_VELOCITY
	animation_player.play("Jump")
	state = MOVE

func slide_state ():
	animation_player.play("Slide")
	run_speed = 2.5
	await animation_player.animation_finished
	state = MOVE

func attack_state ():
	if Input.is_action_just_pressed("Attack"):
		velocity.x = 0
		animation_player.play("Attack1")
		await animation_player.animation_finished
		#attack_freeze ()
		state = MOVE
	
func damage_state ():
	velocity.x = 0
	animation_player.play("Damage")
	await animation_player.animation_finished
	state = MOVE

func on_damage_received (enemy_damage):
	if state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH

	
	print(health)
	
