class_name curve_status extends ingame_status
@export var curve:Curve
func get_percent(game_run_percent:float)->float:
	if curve!=null:
		return curve.sample(game_run_percent)
	return 0
