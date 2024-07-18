extends "res://mats/UI/map/locs/map_aditional_script_tamplate.gd"
signal map_generated
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
func save_data():
	var pos=[]
	for e in exceptions:
		pos.append([e.x,e.y])
	return {
		str(get_path()):{"n":neighbors.duplicate(),"p":pos}
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
var col=13
var row=6
var max_neighbors=[0,0.4,0.3,0.05,0.05]
var neighbors:=[]
var exceptions:=[]

func _pre_ready():
	connect("save_data_changed",Callable(gm,"_save_node"))
	connect("_load_data",Callable(gm,"_load_node"))
	if !gm.sn.has(str(get_path())):
		emit_signal("save_data_changed",save_data())
	else:
		emit_signal("_load_data",self,str(get_path()))
	fnc.rnd.seed=1001
	upd()

func upd():
	if exceptions.is_empty() and neighbors.is_empty():
		var place_count=fnc.rnd.randi_range(col*row,col*row)
		#for e in range(col*row):
			#if fnc._with_chance(0.75):
				#neighbors.append(clamp(fnc._with_chance_ulti(max_neighbors),0,col*row-1)+1)
				#exceptions.append(Vector2(e%col,(e-e%col)/col))
		for e in range(place_count):
			var x=fnc.rnd.randi_range(0,col)
			var y=fnc.rnd.randi_range(0,row)
			while fnc.i_search(exceptions,Vector2(x,y))!=-1:
				x=fnc.rnd.randi_range(0,col)
				y=fnc.rnd.randi_range(0,row)
			neighbors.append(clamp(fnc._with_chance_ulti(max_neighbors),0,place_count-1)+1)
			exceptions.append(Vector2(x,y))
		#exceptions.sort_custom((func(a, b):
			#var dist_a = a.distance_to(Vector2.ZERO)
			#var dist_b = b.distance_to(Vector2.ZERO)
			#return dist_a < dist_b))
	else:
		for e in get_children():
			e.free()
		#print("miner")
	gen_map_v1(exceptions,neighbors)
	emit_signal("map_generated")
func gen_map_v1(positions,neighbors):
	for e in positions:
		var scn=preload("res://mats/UI/map/place/place.tscn").instantiate()
		scn.position=e*48#16+32
		add_child(scn)
	#print(get_child_count())
	await get_tree().process_frame
	var mass:=get_children()
	var d:={}
	var temp_mass=mass.duplicate(true)
	
	for e in mass:
		temp_mass.sort_custom((func(a, b):
			var dist_a = a.global_position.distance_to(e.global_position)
			var dist_b = b.global_position.distance_to(e.global_position)
			return dist_a < dist_b and a!=e and b!=e))
		var local_angs=[]
		for k in range(neighbors[e.get_index()]):
			var ang=fnc.angle(temp_mass[k].global_position.direction_to(e.global_position))
			if e!=temp_mass[k] and local_angs.find(ang)==-1:
				local_angs.append(ang)
				e.neighbors.append(temp_mass[k])
				temp_mass[k].neighbors.append(e)
				if len(temp_mass[k].neighbors)<=3 and fnc._with_chance(0.05):
					#e.secret=true
					temp_mass[k].secret=true
				#await get_tree().process_frame
		#neighbors[e.get_index()]=len(e.neighbors)
	#var e_id=0
	#while e_id<len(mass):
		#var e=mass[e_id]
		#var local_angs=[]
		#var k_id=0
		#while k_id<len(e.neighbors):
			#var k=e.neighbors[k_id]
			#var ang=fnc.angle(k.global_position.direction_to(e.global_position))
			#if local_angs.find(ang)==-1:
				#local_angs.append(ang)
			#else:
				#e.neighbors.remove_at(k_id)
				#k_id-=1
			#k_id+=1
		#e_id+=1
	#await get_tree().process_frame
	#for e in get_children():
		#if dijkstra(e.get_index(),0,false).is_empty():
			#print(e.get_index())
	#print("ended")
	gm.save_file_data()
