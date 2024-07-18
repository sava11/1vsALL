extends Node
@onready var wrld=$world
@onready var locs_cont=$cl/map/map/cont/locs
var cur_loc=null
var game_was_paused:=false
func _ready():
	var lvl=null
	#сделать перемну уровней!
	if !gm.game_prefs.scripts.traied:
		lvl=preload("res://mats/UI/map/locs/training/training.tscn").instantiate()
	else:
		lvl=preload("res://mats/UI/map/locs/generator/lvl_generator.tscn").instantiate()
	locs_cont.add_child(lvl)
	show_lvls()

func _process(delta):
	$cl/game_ui/status/stamina.max_value=gm.player_data.stats["max_stamina"]
	$cl/game_ui/status/stamina.value=gm.player_data.prefs["cur_stm"]
	$cl/game_ui/status/hp.max_value=gm.player_data.stats["hp"]
	$cl/game_ui/status/hp.value=gm.player_data.prefs["cur_hp"]
	$cl/game_ui/status/hp/value/cur.text=str(snapped($cl/game_ui/status/hp.value,0.01))
	$cl/game_ui/status/hp/value/max.text=str(snapped($cl/game_ui/status/hp.max_value,0.01))
	$cl/game_ui/status/stamina/value/cur.text=str(snapped($cl/game_ui/status/stamina.value,0.01))
	$cl/game_ui/status/stamina/value/max.text=str(snapped($cl/game_ui/status/stamina.max_value,0.01))
	$cl/game_ui/status/money.text=str(gm.player_data.stats.money)
	for i in $cl/map.stat_cont.get_children():
		if i.get_node("item_name").text==tr("MONEY"):
			i.set_value(snapped(float($cl/game_ui/status/money.text),0.001))
	if wrld.get_child_count()==1 and wrld.get_child(0).get("timer")!=null:
		if !$cl/game_ui/status/time_cont/time.visible:
			$cl/game_ui/status/time_cont/time.show()
		$cl/game_ui/status/time_cont/time.text=str(snapped(wrld.get_child(0).get("timer").time_left+1,1))
	else:
		$cl/game_ui/status/time_cont/time.hide()
	if Input.is_action_just_pressed("esc"):
		if !$cl/pause.visible:
			if get_tree().paused!=true:
				get_tree().set_deferred("paused",true)
				game_was_paused=true
			$cl/pause.show()
		else:
			_on_cnt_button_down()
				
func show_lvls(b:bool=true):
	if b==true:
		$world.hide()
		$cl/game_ui.hide()
		$cl/map.show()
		#$asp_think.play()
		#$asp_fight.stop()
	else:
		$world.show()
		$cl/game_ui.show()
		$cl/map.hide()
		#$asp_think.stop()
		#$asp_fight.play()
	get_tree().set_deferred("paused",b)

func start_sound_fight():
	$asp_fight.play()
func stop_sound_fight():
	$asp_fight.stop()
func start_sound_think():
	$asp_think.play()
func stop_sound_think():
	$asp_think.stop()
func _on_place_completed():
	if $world.get_child_count()>0 and $world.get_child(0) is level_template:
		$world.get_child(0).queue_free()
	gm.player_data.in_action=""
	gm.save_file_data()
	show_lvls()
func _on_pause_location_added(n):
	if $world.get_child_count()>0 and $world.get_child(0) is level_template:
		$world.get_child(0).queue_free()
	cur_loc=n
	show_lvls(false)
func to_menu():
	get_tree().set_deferred("paused",false)
	get_tree().change_scene_to_file("res://game/menu.tscn")
func exit_from_game():
	get_tree().quit()
func to_settings():
	var scn=preload("res://game/settings.tscn").instantiate()
	$cl.add_child(scn)
	scn.get_node("menu/bc").button_down.connect(Callable(self,"from_settings"))
	$cl/pause.hide()
	scn.z_index=3
func from_settings():
	$cl/pause.show()
func _on_cnt_button_down():
	$cl/pause.hide()
	if game_was_paused:
		get_tree().set_deferred("paused",false)


func _on_retry_button_down():
	for e in $cl/map.map.get_children():
		e.runned=false
	if gm.game_prefs.scripts.traied:
		$cl/map/map/cont/locs/map.set_cur_pos(null)
		gm.game_prefs.seed=randi()
		fnc.rnd.seed=gm.game_prefs.seed
		locs_cont.upd()
	else:
		$cl/map/map/cont/locs/map.set_cur_pos($cl/map/map/cont/locs/map/place)
	if $world.get_child(0) is level_template:
		$world.get_child(0).queue_free()
	#await get_tree().process_frame
	gm.save_file_data()
	show_lvls()
	$cl/game_ui/death.hide()
