class_name enemy_data extends empty_entety_data
@export var enemy_name:String
@export var enemy:PackedScene
@export_range(0.001,1) var percent:float
@export_range(1,99,1,"or_greater") var count_min:int=1:
	set(v):
		if v>count_max:
			count_min=count_max
		else:
			count_min=v
	get:
		return count_min
@export_range(1,99,1,"or_greater") var count_max:int=1: 
	set(v):
		if v<count_min:
			count_max=count_min
		else:
			count_max=v
	get:
		return count_max
