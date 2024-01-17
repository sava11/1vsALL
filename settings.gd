extends Control
var data:Dictionary={
	"size":{"x":800,"y":600},
	"full_size":false,
	"lang":0,
	"sound":{"gm":100,"mn":100}
}
var wins=[[800, 600], [854, 480], [960, 540], [1024, 600], [1024, 768], [1152, 864], [1200, 600], [1280, 720], [1280, 768], [1280, 1024], [1408, 1152], [1440, 900], [1400, 1050], [1440, 1080], [1536, 960], [1536, 1024], [1600, 900], [1600, 1024], [1600, 1200], [1680, 1050], [1920, 1080], [1920, 1200], [2048, 1080], [2048, 1152], [2048, 1536], [2560, 1080], [2560, 1440], [2560, 1600], [2560, 2048], [3200, 1800], [3200, 2048], [3200, 2400], [3440, 1440], [3840, 2160], [3840, 2400], [4096, 2160], [5120, 2880], [5120, 4096], [6400, 4096], [6400, 4800], [7680, 4320], [7680, 4800], [10240, 6480], [11520, 6480]]
func _ready():
	if !FileAccess.file_exists("settings.json"):
		sls.save_data("settings.json",data)
	else:
		data=sls.load_data("settings.json")
	for w in wins:
		if Vector2i(w[0],w[1])<=DisplayServer.screen_get_size():
			$menu/scr_sz/sz.add_item(str(w[0])+"x"+str(w[1]))
	set_data(data)

func set_data(d:Dictionary):
	DisplayServer.window_set_size(Vector2i(d.size.x,d.size.y))
	DisplayServer.window_set_position(DisplayServer.screen_get_size()/2-DisplayServer.window_get_size()/2)
	if d.full_size:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_on_lng_item_selected(d.lang)
	$menu/lng/lng.selected=d.lang
	$menu/snd/c/menu.value=d.sound.mn
	$menu/snd/c/game.value=d.sound.gm
	$menu/fscr/cb.button_pressed=d.full_size
	$menu/scr_sz/sz.selected=fnc.i_search(wins,[int(d.size.x),int(d.size.y)])
func _on_menu_value_changed(value):
	data.sound.mn=value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("menu"), linear_to_db($menu/snd/c/menu.value/100))


func _on_game_value_changed(value):
	data.sound.gm=value


func _on_sz_item_selected(i):
	data.size.x=wins[i][0]
	data.size.y=wins[i][1]
	DisplayServer.window_set_size(Vector2i(data.size.x,data.size.y))
	DisplayServer.window_set_position(DisplayServer.screen_get_size()/2-DisplayServer.window_get_size()/2)
	ProjectSettings.set("display/window/size/window_width_override",data.size.x)
	ProjectSettings.set("display/window/size/window_height_override",data.size.y)


func _on_aply_button_down():
	sls.save_data("settings.json",data)


func _on_bc_button_down():
	get_parent().get_node("bg").show()
	get_parent().get_node("main_menu").show()
	hide()
	set_data(sls.load_data("settings.json"))



func _on_cb_toggled(toggled_on):
	
	data.full_size=toggled_on
	if data.full_size:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_position(DisplayServer.screen_get_size()/2-DisplayServer.window_get_size()/2)


func _on_lng_item_selected(i):
	if i==0:
		TranslationServer.set_locale("ru")
	elif i==1:
		TranslationServer.set_locale("en")
	data.lang=i
	gm.upd_objs()
