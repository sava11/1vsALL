class_name Region extends Resource
@export var color:Color
@export var pos:=Vector2.ZERO
@export_file("*.tscn") var levels:Array[String]=["res://mats/lvls/lvl1/lvl1_1.tscn","res://mats/lvls/lvl1/lvl1_2.tscn"]
@export var level_chances:Array[float]=[0.75,0.25]
@export_file("*.tscn")var boss_path:String
func get_level()->String:
	var lvl:=""
	if levels.size()==level_chances.size() and levels.any((func(x:String):return x!="")) and level_chances.any((func(x:float):return x>0)):
		lvl=levels[fnc._with_chance_ulti(level_chances)]
	else:
		print("region on position ",pos," is corupted")
	return lvl
