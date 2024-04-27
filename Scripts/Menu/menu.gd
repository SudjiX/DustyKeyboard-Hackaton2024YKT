extends Node2D

class_name Main_menu


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels/level_1.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
