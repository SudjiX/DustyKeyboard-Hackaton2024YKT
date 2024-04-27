extends CharacterBody2D

class_name Enemy

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var chase = false
var speed = 60
@onready var animated_sprite_2d = $AnimatedSprite2D
var alive = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	if alive == true:
		if chase == true:
			velocity.x = direction.x * speed
			animated_sprite_2d.play("Walk")
		else:
			velocity.x = 0
			animated_sprite_2d.play("Idle")
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "Player":
		chase = true

func _on_detector_body_exited(body):
	if body.name == "Player":
		chase = false

func _on_death_body_entered(body): #Смерть врага с отталкиванием игрока
	if body.name == "Player":
		body.velocity.y -= 300
		death()
		
func death (): #Функция смерти врага
	alive = false
	animated_sprite_2d.play("Death")
	await animated_sprite_2d.animation_finished
	queue_free()

func _on_damage_zone_body_entered(body): #Игрок получает урон
	if body.name == "Player":
		if alive == true:
			body.health -= 40
