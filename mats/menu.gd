extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#shake($Label,Vector2.UP*4)
	pass
	#grab_focus()
	#$main_menu/cont/buttons/play.call_deferred("grab_focus")
	#gm.set_font(gm.cur_font,theme)
	

func _process(delta):
	pass
##для использования нужно иметь заранее заготовленные анимации для узла AnimationPlayer
##трясёт только по позиции, в анимации может быть множество узлов, но ключевых кадров должно быть РОВНО 3
#func shake(node:CanvasItem,vec:Vector2=Vector2.ZERO,rand_offset:int=4):
	#if vec==Vector2.ZERO:
		#vec=Vector2(randi_range(-rand_offset,rand_offset),randi_range(-rand_offset,rand_offset))
	#var anim_player:AnimationPlayer=$ap
	#var path=str(get_tree().current_scene.get_path_to(node))
	#anim_player.get_animation("shake").track_set_key_value(0,1,node.position+vec)
	#anim_player.play("shake")

func _on_play_button_down():
	#get_tree().change_scene_to_file("res://gameplay_choice.tscn")
	var t=preload("res://gameplay_choice.tscn").instantiate()
	add_child(t)
	$bg.hide()
	$main_menu.hide()

func _on_settings_button_down():
	$bg.hide()
	$main_menu.hide()
	$settings.show()


func _on_exit_button_down():
	get_tree().quit()


func _on_credits_button_down():
	get_tree().change_scene_to_file("res://authors.tscn")




func _on_asp_finished():
	$asp.play()

