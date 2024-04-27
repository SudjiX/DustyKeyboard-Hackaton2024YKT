extends Node2D

@onready var directional_light_2d = $Lights/DirectionalLight2D
@onready var lamp = $Lights/Lamp
@onready var day_text = $PlayerUi/DayText
@onready var day_night = $DayNight
@onready var health_bar = $PlayerUi/TextureProgressBar
@onready var player = $Player/Player
@onready var text_animation = $PlayerUi/TextAnimation


enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var day_count: int

func _ready():
	health_bar.max_value = player.max_health
	health_bar.value = health_bar.max_value 
	day_count = 0
	directional_light_2d.enabled = true
	text_animation.play("Обучение")
	set_day_text()



func morning_state ():
	var tween = get_tree().create_tween()
	tween.tween_property(directional_light_2d, "energy", 0.1, 20)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(lamp, "energy", 0, 60)

func evening_state (): 
	var tween = get_tree().create_tween()
	tween.tween_property(directional_light_2d, "energy", 0.90, 20)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(lamp, "energy", 1.5, 20)

func _on_day_night_timeout():
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	if state < 3:
		state += 1
	else:
		state = MORNING 
		day_count += 1
		set_day_text()
	
func set_day_text ():
	day_text.text = "Время: " + str(day_count)


func _on_player_health_changed(new_health):
	health_bar.value = new_health
