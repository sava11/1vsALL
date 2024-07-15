extends Control
func _ready():
	if !gm.game_prefs.traied:
		gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog1.tres"))
func train_dialog(trained:bool,message_to_train_accepted:bool):
	gm.game_prefs.traied=trained
	gm.game_prefs.message_to_train_accepted=message_to_train_accepted
	gm.save_file_data()
func _on_place_2_choice_panel_showed():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog3.tres"))

func _on_place_2_lvl_start():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog4.tres"))

func _on_place_2_lvl_end():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog5.tres"))


func _on_place_3_choice_panel_showed():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog7.tres"))
