extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0
var health = 100
var money = 0
#Гравитация
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta
#Прыжок
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("Jump")

 #Движение влево и право
	var direction = Input.get_axis("Move_Left", "Move_Right")
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			animated_sprite_2d.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animated_sprite_2d.play("Idle")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
	if velocity.y > 0:
		animated_sprite_2d.play("Fall")
		
	if health <= 0:
		health = 0
		#animated_sprite_2d.play("Death")
		#await animated_sprite_2d.animation_finished
		#queue_free()
		get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")

	move_and_slide()
