extends "res://mats/UI/map/locs/map_aditional_script_tamplate.gd"

func start_dialog():
	if !gm.game_prefs.scripts.traied and !gm.game_prefs.scripts.lvl1_runned:
		gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog1.tres"))
func start_dialog_ended():
	gm.game_prefs.scripts.lvl1_runned=true
	gm.save_file_data()
func train_dialog(trained:bool,message_to_train_accepted:bool):
	gm.game_prefs.scripts.traied=trained
	gm.game_prefs.scripts.message_to_train_accepted=message_to_train_accepted
	if gm.game_prefs.scripts.traied:
		gm.sn.erase(str(get_path()))
		name="deled_"+name
		var lvl_gen=preload("res://mats/UI/map/locs/generator/lvl_generator.tscn").instantiate()
		get_parent().add_child(lvl_gen)
		remove_from_group("SN")
		queue_free()
	gm.save_file_data()
func _on_place_2_choice_panel_showed():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog3.tres"))

func _on_place_2_choice_panel_hided():
	gm.make_dialog(null)


func _on_place_2_lvl_start():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog4.tres"))


func _on_place_2_runned_changed(res):
	if res and !gm.game_prefs.scripts.lvl2_runned:
		gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog5.tres"))
		gm.game_prefs.scripts.lvl2_runned=true
		gm.save_file_data()


func _on_place_5_runned_changed(res):
	if res and !gm.game_prefs.scripts.lvl5_runned:
		gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/train_end.tres"))
		gm.game_prefs.scripts.lvl5_runned=true
		gm.save_file_data()



func _on_place_7_lvl_end():
	gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/train_end.tres"))
	#gm.game_prefs.scripts.lvl5_runned=true
	#gm.save_file_data()
