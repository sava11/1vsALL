@tool
extends Control
@export_range(0,9999) var max_offset:int=4
@export_enum("left","center","right")var alignment:int=0
#@onready var usize=size
#@onready var uposition=position
func clamp_bottom(v,bottom):
	if v>bottom:return v
	else:return bottom
func clamp_top(v,top):
	if v<top:return v
	else:return top
func get_visible_children(include:bool=false):
	var exit=0
	for e in get_children(include):
		exit+=int(e.visible)
	return exit
func _process(delta):
	var c:float=get_visible_children()
	if c>0:
		for i in range(get_child_count()):
			if get_child(i).visible:
				var t=get_child_count()-c
				var e =get_child(i)
				var cscale=(size-e.size)/((e.size)*(c-1))
				var offset=clamp_top((e.size.x+max_offset)*cscale.x-
				e.size.x-max_offset*cscale.x,max_offset)
				var dif=clamp_bottom(size.x-(e.size.x+abs(offset))*c+max_offset,0)
				e.position=Vector2((e.size.x+offset)*(i-t)+dif/2*alignment,(size.y-e.size.y)*0.5)
