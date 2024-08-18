extends Node
func save_data(path:String,data:Dictionary):
	var save_game := FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(data))
	save_game.close()
func load_data(path:String):
	if (FileAccess.file_exists(path)):
		var save_game := FileAccess.open(path, FileAccess.READ)
		save_game.open(path, FileAccess.READ)
		if save_game.get_length()!=0:
			return JSON.parse_string(save_game.get_line())
		else:
			print("save is clear")
		save_game.close()
	else:
		print("save isn't exists")
