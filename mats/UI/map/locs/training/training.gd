extends "res://mats/UI/map/locs/map_aditional_script_tamplate.gd"
func _process(delta):
	if current_pos!=null:
		for cur_place in get_children():
			cur_place.player_here=cur_place==current_pos
			if cur_place.player_here and !cur_place.last_player_here:
				set_cur_pos(cur_place)
			cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1)
			

func start_dialog():
	if !gm.game_prefs.scripts.traied and !gm.game_prefs.scripts.lvl1_runned:
		gm.make_dialog(preload("res://mats/UI/dialog/data/dialogs/story/story_dialog1.tres"))
func start_dialog_ended():
	gm.game_prefs.scripts.lvl1_runned=true
	gm.save_file_data()
func train_dialog(trained:bool,message_to_train_accepted:bool):
	gm.game_prefs.scripts.traied=trained
	gm.game_prefs.scripts.message_to_train_accepted=message_to_train_accepted
	gm.save_file_data()
	if gm.game_prefs.scripts.traied:
		name="deled_"+name
		var lvl_gen=preload("res://mats/UI/map/locs/generator/lvl_generator.tscn").instantiate()
		get_parent().add_child(lvl_gen)
		queue_free()
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

