@tool
class_name place extends Control
signal player_in()
signal choice_panel_showed()
signal choice_panel_hided()
signal choice_shop()
signal choice_shop_out()
signal choice_play()
signal choice_cancel()
signal lvl_start
signal lvl_end
signal runned_changed(res:bool)
signal lvl_timed_event(event_id:int)
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
var player_here:bool=false
var last_player_here:bool=false

@export_group("level_params")
@export_file("*.tscn") var level:String
@export var level_time:float=45.0
@export var time_events:PackedFloat32Array
@export_group("place")
@export var secret:bool=false
@export var runned:bool=false
@onready var last_runned=runned
@export var local_difficulty_add_step:float=0
@export_subgroup("statuses")
@export var arena:arena_action
@export var shop:=false
@export_group("place")
@export var ingame_statuses:Array[ingame_status]
@export var neighbors:Array[place]
@export_group("colors")
var original:Color
@export var active:float=1
@export var unactive:float=1
@export_subgroup("image_colors")
@export var arena_color:Color
@export var player_color:Color
@export var boss_color:Color
@export var shop_color:Color
@export var secret_color:Color
#var nearst_unconnected:Array[place]=[]
var place_panel_node=null
var map:Node
var lvl:level_template
func save_data():
	return {
		str(get_path()):{
			"runned":runned,
		}
	}
func load_data(n:Dictionary):
	runned=n["runned"]
#func add_neighbor(n:place):
	#neigbors.append(n)
	#n.neigbors.append(self)
#func remove_neighbor(n:place):
	#neigbors.remove_at(neigbors.find(n))
	#n.neigbors.remove_at(n.neigbors.find(self))
var t:=false
func img_think():
	if !player_here and !secret:
		if shop:
			$visual.texture=preload("res://mats/UI/map/imgs/shop.png")
			if arena!=null and !runned:
				original=boss_color
			else:
				original=shop_color
		elif arena!=null and !runned and arena.has_bosses():
			$visual.texture=preload("res://mats/UI/map/imgs/boss.png")
			original=boss_color
		else:
			$visual.texture=null
			original=arena_color
	else:
		if secret and !player_here:
			$visual.texture=preload("res://mats/UI/map/imgs/secret.png")
			original=secret_color
		else:
			$visual.texture=preload("res://mats/UI/map/imgs/hero.png")
			original=player_color
func _ready():
	name="place"+str(get_index())
	map=get_node_or_null("../../../../../")
	if !Engine.is_editor_hint():
		if map!=null:
			map.connect("location_added",Callable(func(lvl):map.cur_loc=lvl))
		connect("save_data_changed",Callable(gm,"_save_node"))
		connect("_load_data",Callable(gm,"_load_node"))
		if !gm.sn.has(str(get_path())):
			emit_signal("save_data_changed",save_data())
		else:
			emit_signal("_load_data",self,str(get_path()))
		var m=get_parent().get_children()
		var d={}
		#m.sort_custom(Callable(func(a, b):
			#var dist_a = a.global_position.distance_to(global_position)
			#var dist_b = b.global_position.distance_to(global_position)
			#return dist_a < dist_b and a!=self and b!=self))
		#m.filter((func(a):
			#var dist_a = a.global_position.distance_to(global_position)
			#var dist_b = b.global_position.distance_to(global_position)
			#))
		#for n in neighbors:
			#var l=Line2D.new()
			#l.width=2
			#l.add_point(size/2)
			#l.add_point((n.global_position-global_position+size)/2)
			#$lines.add_child(l)
	img_think()
	$nm.text=name#"place"+str(get_index())
func _draw():
	for n in neighbors:
		if is_instance_valid(n) and n.visible:
			draw_line(size/2,(n.global_position-global_position+size)/2,Color.LIGHT_SLATE_GRAY,2)
var stage:bool=false
var time:float=0
func _process(delta):
	if !Engine.is_editor_hint():
		time+=delta
	queue_redraw()
	if !$btn.disabled:$arena.self_modulate=Color(original.r*active,original.g*active,original.b*active)
	else:$arena.self_modulate=Color(original.r*unactive,original.g*unactive,original.b*unactive)
	if stage:
		$visual.self_modulate=Color(original.r*active,original.g*active,original.b*active)
	else:
		$visual.self_modulate=Color(original.r*unactive,original.g*unactive,original.b*unactive)
	if time>=1 and player_here:
		time=0
		stage=!stage
	if !player_here:
		stage=false
	if last_runned!=runned:
		if !Engine.is_editor_hint():
			emit_signal("runned_changed",runned)
		last_runned=runned
		img_think()
	
	if last_player_here!=player_here:
		img_think()
		if player_here:
			emit_signal("player_in")
		if place_panel_node!=null and !player_here:
			cancel()
		
		last_player_here=player_here
	if shop and !shop_changed:
		img_think()
		shop_changed=true
	if !shop and shop_changed:
		img_think()
		shop_changed=false
	if arena!= null and !arena_changed:
		img_think()
		arena_changed=true
	if arena==null and arena_changed:
		img_think()
		arena_changed=false
	if secret!=secret_changed:
		img_think()
		secret_changed=secret
	if !Engine.is_editor_hint():
		if secret:
			if neighbors.any(Callable(
				func(x:place):
					return x.player_here and x.neighbors.find(self)>-1)) or player_here:
				show()
			else:hide()
	#show()
var shop_changed:bool=false
var arena_changed:bool=false
var secret_changed:bool=false
func create_panel():
	if place_panel_node==null:
		place_panel_node=preload("res://mats/UI/map/place/place_item_panel.tscn").instantiate()
		add_child(place_panel_node)
		var pnl_glb_size=Vector2(place_panel_node.size.x,place_panel_node.size.y)*place_panel_node.scale
		var p_pos=global_position-Vector2(pnl_glb_size.x/2,-pnl_glb_size.y/2)+Vector2(size.x/2,size.y/2)
		place_panel_node.global_position=p_pos
		emit_signal("choice_panel_showed")
	else:
		place_panel_node.queue_free()
		emit_signal("choice_panel_hided")

func _on_button_down():
	if !runned:
		if arena!=null:
			create_panel()
			for e in ingame_statuses:
				if e!=null and e.status!="":
					place_panel_node.add_item(load(gm.objs.stats[e.status].i),
					tr(gm.objs.stats[e.status].ct),e.value,gm.objs.stats[e.status].postfix)
			place_panel_node.connect_to(self,"play","cancel")
		elif shop:
			create_panel()
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
		else:
			runned=true
			var temp_d={}
			for e in ingame_statuses:
				temp_d.merge({e.status:e.value})
			gm.merge_stats(temp_d)
			if map!=null:
				map.upd_by_sts()
	else:
		if shop:
			create_panel()
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
func to_shop():
	emit_signal("choice_shop")
	map.shop_items.merge({self:{"":0}})
	map.emit_signal("in_shop")
	
func _time_events(step_id:int):
	emit_signal("lvl_timed_event",step_id)
func play():
	emit_signal("choice_play")
	var level_container=get_parent().level_container
	if level_container!=null and level!="":
		lvl=load(level).instantiate()
		lvl.time=level_time
		lvl.enemys_data=arena
		lvl.completed.connect(Callable(map,"level_completed").bind(self))
		lvl.uncompleted.connect(
			Callable(self,"emit_signal").bind("runned_changed",runned))
		lvl.uncompleted.connect(Callable(map,"_on_player_no_he"))
		emit_signal("lvl_start")
		lvl.time_events=time_events.duplicate()
		lvl.time_event.connect(Callable(self,"_time_events"))
		map.emit_signal("location_added",lvl)
		level_container.add_child(lvl)
		level_container.move_child(lvl,0)
		gm.player_data.in_action=str(get_path())
		#gm.save_file_data()
	else:
		emit_signal("lvl_start")
		runned=true
		#get_parent().current_pos=self
		emit_signal("runned_changed",runned)
		emit_signal("lvl_end")
	place_panel_node.queue_free()
func cancel():
	emit_signal("choice_cancel")
	place_panel_node.queue_free()
	emit_signal("choice_panel_hided")
func shop_cancel():
	emit_signal("choice_shop_out")
	place_panel_node.queue_free()
	emit_signal("choice_panel_hided")

func _on_runned_changed(res:bool):
	if res:
		gm.player_data.runned_lvls+=1
	emit_signal("lvl_end")
