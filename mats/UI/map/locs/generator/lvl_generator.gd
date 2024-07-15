extends Control
signal map_generated
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
func save_data():
	var pos=[]
	for e in exceptions:
		pos.append([e.x,e.y])
	return {
		str(get_path()):{"n":neighbors,"p":pos}
	}

func load_data(n:Dictionary):
	neighbors=n.n
	exceptions=[]
	for e in n.p:
		exceptions.append(Vector2(e[0],e[1]))
	pass
#func data_to_save():
	#return {
		#"n":neighbors,
		#"p":pos_to_dict(get_children())
		#}
#func pos_to_dict(mass:Array[Node])->Dictionary:
	#var d:={}
	#for e in mass:
		#d.merge({e.get_index():{"x":e.global_position.x,"y":e.global_position.y}})
	#return d
var col=25
var row=20
var max_neighbors=[0,0.4,0.3,0.05,0.05]
var neighbors:=[]
var exceptions:=[]

func _ready():
	connect("save_data_changed",Callable(gm,"_save_node"))
	connect("_load_data",Callable(gm,"_load_node"))
	if !gm.sn.has(str(get_path())):
		emit_signal("save_data_changed",save_data())
	else:
		emit_signal("_load_data",self,str(get_path()))
	upd()
func upd():
	if exceptions.is_empty() and neighbors.is_empty():
		var place_count=fnc.rnd.randi_range(col*row/4,col*row)
		for e in range(place_count):
			var x=fnc.rnd.randi_range(0,col)
			var y=fnc.rnd.randi_range(0,row)
			while fnc.i_search(exceptions,Vector2(x,y))!=-1:
				x=fnc.rnd.randi_range(0,col)
				y=fnc.rnd.randi_range(0,row)
			neighbors.append(fnc._with_chance_ulti(max_neighbors)+1)
			exceptions.append(Vector2(x,y))
		exceptions.sort_custom((func(a, b):
			var dist_a = a.distance_to(Vector2.ZERO)
			var dist_b = b.distance_to(Vector2.ZERO)
			return dist_a < dist_b and a!=Vector2.ZERO and b!=Vector2.ZERO))
	else:print("miner")
	gen_map_v1(exceptions,neighbors)
	emit_signal("map_generated")
func gen_map_v1(positions,neighbors):
	for e in positions:
		var scn=preload("res://mats/UI/map/place/place.tscn").instantiate()
		scn.position=e*48#16+32
		add_child(scn)
	print(get_child_count())
	var mass:=get_children()
	var d:={}
	var temp_mass=mass.duplicate(true)
	for e in mass:
		temp_mass.sort_custom((func(a, b):
			var dist_a = a.global_position.distance_to(e.global_position)
			var dist_b = b.global_position.distance_to(e.global_position)
			return dist_a < dist_b and a!=e and b!=e))
		var local_angles=[]
		for k in range(neighbors[e.get_index()]):
			var cur_ang:float=fnc.angle(e.global_position-temp_mass[k].global_position)
			if local_angles.find(cur_ang)==-1:
				local_angles.append(cur_ang)
				e.neighbors.append(temp_mass[k])
				#if len(mass[id].neighbors)<len(max_neighbors) and fnc._with_chance(0.9):
				temp_mass[k].neighbors.append(e)
		neighbors[e.get_index()]=len(e.neighbors)
