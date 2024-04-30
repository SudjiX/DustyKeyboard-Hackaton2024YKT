extends CharacterBody2D

class_name Enemy_ground

enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var direction
var damage = 20
var health = 50

func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	Signals.connect("player_attack", Callable (self, "_on_damage_received"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if state == CHASE:
		chase_state()
	move_and_slide()

func _on_player_position_update(player_pos):
	player = player_pos
	chase_state()
	
func _on_attack_range_body_entered(_body):
	state = ATTACK

func idle_state():
	animation_player.play("Idle")
	state = CHASE
	
func attack_state():
	animation_player.play("Attack")
	await animation_player.animation_finished
	state = RECOVER

func chase_state ():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		animated_sprite_2d.flip_h = false
		$AttackDirection.rotation_degrees = 0	

func damage_state ():
	animation_player.play("Damage")
	await  animation_player.animation_finished
	state = IDLE
	
func death_state ():
	animation_player.play("Death")
	await animation_player.animation_finished
	queue_free()
	
func recover_state ():
	animation_player.play("Recover")
	await animation_player.animation_finished
	state = IDLE



func _on_damage_received (player_damage):
	health -= player_damage
	state = DAMAGE
	print (player_damage)
	if health <= 0:
		state = DEATH
	else:
		state = DAMAGE
	

func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage)
