extends Node
@onready var enemy_path=$world/ent/enemys
@onready var wrld=$world
func _ready():
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
	$cl/game_ui/status/money.text=str(gm.player_data.prefs.money)
	if (wrld.get_child(0) is level_template) and wrld.get_child(0).has_node("Timer"):
		$cl/game_ui/status/time_cont/time.text=str(snapped(wrld.get_child(0).get_node("Timer").time_left,1))



func show_lvls(b:bool=true):
	if b==true:
		start_sound_think()
		stop_sound_fight()
		$world.hide()
		$cl/game_ui.hide()
		$cl/pause.show()
	else:
		stop_sound_think()
		start_sound_fight()
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
func _on_pause_location_added(n):
	if $world.get_child(0) is level_template:$world.get_child(0).queue_free()
	show_lvls(false)
