class_name boss_data extends empty_entety_data
@export var boss_name:String
@export var boss:PackedScene
@export_range(0.001,1) var percent:float
@export_range(1,99,1,"or_greater") var count:int=1

