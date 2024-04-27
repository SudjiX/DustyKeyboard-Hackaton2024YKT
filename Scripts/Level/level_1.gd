extends Node2D

@onready var directional_light_2d = $Lights/DirectionalLight2D
@onready var lamp = $Lights/Lamp
@onready var day_text = $PlayerUi/DayText
@onready var day_night = $DayNight

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var day_count: int

func _ready():
	day_count = 0
	directional_light_2d.enabled = true
	set_day_text()


func morning_state ():
	var tween = get_tree().create_tween()
	tween.tween_property(directional_light_2d, "energy", 0.1, 2)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(lamp, "energy", 0, 2)

func evening_state (): 
	var tween = get_tree().create_tween()
	tween.tween_property(directional_light_2d, "energy", 0.90, 2)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(lamp, "energy", 1.5, 2)

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
	day_text.text = "День: " + str(day_count)
