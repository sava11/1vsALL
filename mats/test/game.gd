extends Node
@onready var enemy_path=$world/ent/enemys
@onready var wrld=$world
var cur_loc=null
func _ready():
	recreate_player()
	show_lvls()
func recreate_player():
	if has_node("world/ent/player"):
		var n=$world/ent/player
		n.name+="_deleting"
		n.queue_free()
	var plr=preload("res://mats/player/warrior.tscn").instantiate()
	var rt=RemoteTransform2D.new()
	$world/ent.add_child(plr)
	rt.remote_path=$cam.get_path()
	rt.update_rotation=false
	rt.update_scale=false
	plr.add_child(rt)
	plr.hb.connect("no_he",Callable($cl/pause,"_on_player_no_he"))
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
	for i in $cl/pause.stat_cont.get_children():
		if i.get_node("item_name").text==tr("MONEY"):
			i.set_value(snapped(float($cl/game_ui/status/money.text),0.001))
	if (wrld.get_child(0) is level_template) and wrld.get_child(0).get("timer")!=null:
		if !$cl/game_ui/status/time_cont/time.visible:
			$cl/game_ui/status/time_cont/time.show()
		$cl/game_ui/status/time_cont/time.text=str(snapped(wrld.get_child(0).get("timer").time_left+1,1))
	else:
		$cl/game_ui/status/time_cont/time.hide()

func show_lvls(b:bool=true):
	if b==true:
		#start_sound_think()
		#stop_sound_fight()
		$world.hide()
		$cl/game_ui.hide()
		$cl/pause.show()
	else:
		#stop_sound_think()
		#start_sound_fight()
		$world.show()
		$cl/game_ui.show()
		$cl/pause.hide()
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
	if $world.get_child(0) is level_template:
		$world.get_child(0).queue_free()
	gm.player_data.in_action=""
	gm.player_data.prefs.cur_hp=gm.player_data.stats.hp
	get_tree().current_scene.recreate_player()
	gm.save_file_data()
	show_lvls()


func _on_pause_location_added(n):
	if $world.get_child(0) is level_template:
		$world.get_child(0).queue_free()
	for e in $world/ent/enemys.get_children():
		e.queue_free()
	cur_loc=n
	show_lvls(false)
