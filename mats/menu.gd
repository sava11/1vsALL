extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#grab_focus()
	#$main_menu/cont/buttons/play.call_deferred("grab_focus")
	gm.set_font(gm.cur_font,theme)

func _process(delta):
	pass


func _on_play_button_down():
	get_tree().change_scene_to_file("res://gameplay_choice.tscn")


func _on_exit_button_down():
	get_tree().quit()


func _on_credits_button_down():
	get_tree().change_scene_to_file("res://authors.tscn")

func _on_ru_button_down():
	TranslationServer.set_locale("ru")
	gm.upd_objs()

func _on_en_button_down():
	TranslationServer.set_locale("en")
	gm.upd_objs()
