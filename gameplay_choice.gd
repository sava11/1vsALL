extends Control
func _on_button_button_down():
	gm.cur_gameplay_type=gm.gameplay_type.clasic
	get_tree().change_scene_to_file("res://mats/game.tscn")
	

func _on_button_2_button_down():
	gm.cur_gameplay_type=gm.gameplay_type.bossrush
	get_tree().change_scene_to_file("res://mats/game.tscn")


func _on_button_3_button_down():
	gm.cur_gameplay_type=gm.gameplay_type.inf


func _on_back_button_down():
	get_tree().change_scene_to_file("res://menu.tscn")
