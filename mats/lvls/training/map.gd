extends Panel
@onready var ars_cont:=$hbc/vbc/map/gc
@export var max_button_size:=Vector2(150,70)
@export var border_offset_size:=Vector2(4,4)
@export var arenas:PackedVector2Array =[
	Vector2(0,-2),Vector2(1,-2),Vector2(2,-2),Vector2(3,-2),Vector2(4,-2),
	Vector2(0,-1),Vector2(1,-1),Vector2(2,-1),Vector2(3,-1),Vector2(4,-1),
	Vector2(0,0),Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0),
	Vector2(0,1),Vector2(1,1),Vector2(2,1),Vector2(3,1),Vector2(4,1),
	Vector2(0,2),Vector2(1,2),Vector2(2,2),Vector2(3,2),Vector2(4,2),
]
@export var start_pos:Vector2i
var current_pos:Vector2i
func _ready():
	cr_btns()
func _process(delta):
	pass
func cr_btns():
	for e in ars_cont.get_children():
		e.queue_free()
	var max_x:=0
	var min_x:=0
	var max_y:=0
	var min_y:=0
	for i in range(len(arenas)-1):
		if arenas[i].x>arenas[max_x].x:
			max_x=i
		if arenas[i].x<arenas[min_x].x:
			min_x=i
		if arenas[i].y>arenas[max_y].y:
			max_y=i
		if arenas[i].y<arenas[min_y].y:
			min_y=i
	#print(arenas[max_x].x," ",arenas[min_x].x, " ",arenas[max_y].y," ",arenas[min_y].y)
	var count_x=arenas[max_x].x-arenas[min_x].x+1
	var count_y=arenas[max_y].y-arenas[min_y].y+1
	#print(Vector2(count_x,count_y))
	var btn_size:Vector2=((ars_cont.size/Vector2(count_x,count_y)-border_offset_size/4).snapped(Vector2(0.01,0.01))).clamp(Vector2(0,0),max_button_size)
	#print(btn_size)
	for e in arenas:
		var b=preload("res://mats/lvls/training/button/arena.tscn").instantiate()
		b.size=btn_size-border_offset_size
		b.position=(e-Vector2(arenas[min_x].x,arenas[min_y].y))*btn_size+border_offset_size
		ars_cont.add_child(b)
func upd_button_data():pass
