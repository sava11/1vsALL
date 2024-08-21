extends Control
var tp=[]
var cur_name=""
# Called when the node enters the scene tree for the first time.
func _ready():
	gm.player_data=gm.start_player_data.duplicate(true)
	gm.game_prefs=gm.start_game_prefs.duplicate(true)
	for e in DirAccess.get_files_at(gm.save_path):
		if e.contains(gm.suffix):
			var f=FileAccess.open(gm.save_path+"/"+e,FileAccess.READ)
			var data=JSON.parse_string(f.get_line())
			tp.append(e.split(".")[0])
			if f.get_length()!=0 and data!=null:
				data=data["/root/gm"]
				var save_obj=preload("res://mats/test/save_item/save_item.tscn").instantiate()
				save_obj.get_node("data/cont/death/value").text=str(data.player_data.deaths)
				save_obj.get_node("data/cont/lvls/value").text=str(data.player_data.runned_lvls)
				save_obj.get_node("data/cont/seed/num").text=str(data.game_prefs.seed)
				for bss in save_obj.get_node("data/cont/bosses").get_children():
					bss.visible=bss.get_index()<data.game_prefs.bosses_died
				save_obj.get_node("Panel/btns/Button").button_down.connect(
					Callable(func():
						gm.set_dark()
						gm.darked.connect((func(x:bool):
							gm.fname=e.split(".")[0]
							gm.load_file_data()
							gm.player_data.runned_lvls=0
							get_tree().change_scene_to_file("res://mats/test/game.tscn")))
						))
				save_obj.get_node("Panel/btns/del").button_down.connect(Callable(
					func():
						DirAccess.remove_absolute(gm.save_path+"/"+e)
						save_obj.queue_free()))
				$sc/saves.add_child(save_obj)
	var max_id=0
	for e in tp:
		if max_id<int(e):
			max_id=int(e)
	cur_name="save"+str(max_id+1)
		#$saves.add_child()

func _on_button_button_down():
	gm.fname=cur_name
	if gm.game_prefs.seed==-1:
		var t=fnc.rnd.state
		gm.game_prefs.seed=fnc.rnd.randi()
		print(gm.game_prefs.seed)
		fnc.rnd.state=t
		fnc.rnd.seed=gm.game_prefs.seed
	gm.save_file_data()
	gm.set_dark()
	gm.darked.connect((func(x:bool):
		get_tree().change_scene_to_file("res://mats/test/game.tscn")))
	


func _on_back_button_down():
	get_tree().change_scene_to_file("res://game/menu.tscn")
