extends Control
var cur_name=""
# Called when the node enters the scene tree for the first time.
func _ready():
	for e in DirAccess.get_files_at(gm.save_path):
		var f=FileAccess.open(gm.save_path+"/"+e,FileAccess.READ)
		var data={}
		if f.get_length()!=0:
			data=JSON.parse_string(f.get_line())["/root/gm"]
			var save_obj=preload("res://mats/test/save_item/save_item.tscn").instantiate()
			save_obj.get_node("cont/death/value").text=str(data.player_data.deaths)
			save_obj.get_node("cont/lvls/value").text=str(data.player_data.runned_lvls)
			save_obj.get_node("Button").button_down.connect(
				Callable(func():
					gm.fname=e
					gm.load_file_data()
					get_tree().change_scene_to_file("res://mats/test/game.tscn")))
			$saves.add_child(save_obj)
		#$saves.add_child()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
