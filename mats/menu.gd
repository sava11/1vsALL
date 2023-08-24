extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#var ii:float=0.3
	#var p:float=0.01
	#for e in range(20):
	#	ii=ii-ii*p
	#	print(ii)
	$wis/img.texture=load(gm.objs.player[gm.player_type].img)
	$wis/img.hframes=gm.objs.player[gm.player_type].hframes


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_down():
	get_tree().change_scene_to_file("res://mats/game.tscn")


func _on_exit_button_down():
	get_tree().quit()


func _on_credits_button_down():
	get_tree().change_scene_to_file("res://authors.tscn")


func _on_left_button_down():
	gm.player_type=(len(gm.player_types)+gm.player_type-1)%len(gm.player_types)
	$wis/img.texture=load(gm.objs.player[gm.player_type].img)
	$wis/img.hframes=gm.objs.player[gm.player_type].hframes


func _on_right_button_down():
	gm.player_type=abs(gm.player_type+1)%len(gm.player_types)
	$wis/img.texture=load(gm.objs.player[gm.player_type].img)
	$wis/img.hframes=gm.objs.player[gm.player_type].hframes


func _on_ru_button_down():
	TranslationServer.set_locale("ru")
	gm.upd_objs()
	pass # Replace with function body.


func _on_en_button_down():
	TranslationServer.set_locale("en")
	gm.upd_objs()
