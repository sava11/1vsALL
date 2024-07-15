extends Control
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
func save_data():
	return {
		str(get_path()):data_to_save()
	}
func data_to_save():
	pass
func load_data(n:Dictionary):
	pass
func post_ready():pass
func _ready():
	connect("save_data_changed",Callable(gm,"_save_node"))
	connect("_load_data",Callable(gm,"_load_node"))
	if !gm.sn.has(str(get_path())):
		emit_signal("save_data_changed",save_data())
	else:
		emit_signal("_load_data",self,str(get_path()))
	post_ready()
