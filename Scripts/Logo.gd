extends Node2D

class_name Logo

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("Logo")

func _unhandled_key_input(_event):
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")
