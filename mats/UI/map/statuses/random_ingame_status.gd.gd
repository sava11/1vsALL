class_name random_ingame_status extends ingame_status
@export_group("generation","generation")
@export_range(0,5,1,"or_greater") var step:int=3
@export_range(0,1)var positive_chance:float=0.5
@export_group("positive value","p_value")
@export var p_value_from:float
@export var p_value_to:float
@export_group("negative value","n_value")
@export var n_value_from:float
@export var n_value_to:float
