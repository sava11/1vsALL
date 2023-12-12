extends Node
@export var active:bool=false
@export_range(1,9999) var max_stage_points:int=1
@export_range(0,99999999) var max_value:float
@export var centerize:bool
signal stage_changed(curent_stage:int)
var stages=[]
var cur_stage=-1
# Called when the node enters the scene tree for the first time.
func think():
	for e in range(max_stage_points):
		stages.append(e*(max_value/max_stage_points)+(max_value/max_stage_points/2)*int(centerize))
		cur_stage=e
func remove_stage(i:int):
	stages.remove_at(i)
	cur_stage=i-1
	emit_signal("stage_changed",cur_stage)
