extends Node
const fformat="1vA"
var lpath="res://"
const fname="data"
var sd={
	"dinamic":{
		
	},
	"static":{
		
	}
}
func save_data():
	var path=lpath+fname+"."+fformat
	var save_game := FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(sd))
	save_game.close()
func load_data():
	var path=lpath+fname+"."+fformat
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


