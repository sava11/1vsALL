extends Node
func _ready():
	show_lvls()
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
