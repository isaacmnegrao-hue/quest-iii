extends Control

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/fase1.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
