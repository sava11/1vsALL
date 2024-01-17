extends Control

var train=false
func _ready():
	train=gm.gameplay_type.train==get_node("../../").gameplay
	if train:
		mouse_filter=Control.MOUSE_FILTER_STOP
		var b=set_massage("WELCOME_TO_TRAINING",fnc.get_view_win()/2-Vector2(208,128)/2,Vector2(208,128),fnc.get_view_win()/2)
		b.connect("button_down",Callable(self,"_this_is_stats"))
func set_massage(msg:String,pos:Vector2,msg_size:Vector2,target:Vector2, translate:bool=true)->Button:
	var m=preload("res://mats/UI/map/massages/massage.tscn").instantiate()
	m.text=msg
	m.position=pos
	m.size=msg_size*2
	m.viewport_target=target
	add_child(m)
	return m.get_node("b")
func _this_is_stats():
	var s=get_parent().get_node("map/stats").size
	var b=set_massage("THIS_IS_STATS",fnc.get_view_win()/2-Vector2(208,128)/2,Vector2(208,128),get_parent().get_node("map/stats").position+Vector2(s.x,s.y/4))
	b.connect("button_down",Callable(self,"_this_is_inv"))
func _this_is_inv():
	var s=get_parent().get_node("map/arenas/hc").size
	var b=set_massage("THIS_IS_INV",fnc.get_view_win()/2-Vector2(208,128)/2,Vector2(208,128),get_parent().get_node("map/arenas/hc").global_position+Vector2(s.x/4,s.y/2))
	b.connect("button_down",Callable(self,"_this_is_map"))
func _this_is_map():
	var s=get_parent().get_node("map/arenas/gc").size
	var b=set_massage("THIS_IS_MAP",fnc.get_view_win()/2-Vector2(208,128)/2,
	Vector2(208,128),get_parent().get_node("map/arenas/gc").global_position+Vector2(8,s.y/2))
	b.connect("button_down",Callable(self,"_this_is_arena").bind(1))
func _this_is_arena(id:int):
	var s=get_parent().get_node("map/arenas/gc").get_child(id)
	var type:="NULL"
	if s.shop==1:
		type="SHOP"
	elif s.shop==2:
		type="OCUPED_SHOP"
	elif s.exit:
		type="EXIT"
	else:
		type="ARENA"
	var b=set_massage("THIS_IS_"+type,
	fnc.get_view_win()/2-Vector2(208,128)/2,Vector2(208,128),
	s.global_position+Vector2(s.size.x/2,s.size.y/2))
	if id==2:
		b.connect("button_down",Callable(self,"_this_is_arena").bind(4))
	if id==1:
		b.connect("button_down",Callable(self,"_this_is_arena").bind(2))
	if id>=4:
		b.connect("button_down",Callable(self,"_this_is_end_of_train"))

func _this_is_end_of_train():
	var b=set_massage("TRAINING_END",fnc.get_view_win()/2-Vector2(208,128)/2,Vector2(208,128),fnc.get_view_win()/2)
	b.connect("button_down",func():mouse_filter=Control.MOUSE_FILTER_IGNORE);
