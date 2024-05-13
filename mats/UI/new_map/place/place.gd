@tool
class_name place extends Control
var player_here:bool=false
var last_player_here:bool=false
@export_group("level_params")
@export_file("*.tscn") var level:String
@export var level_time:float=45.0
@export_group("place")
@export var secret:bool=false
@export var runned:bool=false
@onready var last_runned=runned
@export var local_difficulty_add_step:float=0
@export_subgroup("statuses")
@export var arena:arena_action
@export var shop:shop_action
@export_group("place")
@export var ingame_statuses:Array[ingame_status]
@export var neighbors:Array[place]
@export var place_panel_node:Panel
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
var map:Node
var lvl:level_template
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
signal runned_changed(res:bool)
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
func img_think():
	if !player_here and !secret:
		if shop!=null:
			$visual.texture=preload("res://mats/UI/new_map/imgs/shop.png")
			if arena!=null and !runned:
				original=boss_color
			else:
				original=shop_color
		elif arena!=null and !runned and arena.has_bosses():
			$visual.texture=preload("res://mats/UI/new_map/imgs/boss.png")
			original=boss_color
		else:
			$visual.texture=null
			original=arena_color
	else:
		if secret:
			$visual.texture=preload("res://mats/UI/new_map/imgs/secret.png")
			original=secret_color
		else:
			$visual.texture=preload("res://mats/UI/new_map/imgs/hero.png")
			original=player_color
func _ready():
	map=get_node("../../../../../")
	if !Engine.is_editor_hint():
		map.connect("location_added",Callable(func(lvl):map.cur_loc=lvl))
		connect("save_data_changed",Callable(gm,"_save_node"))
		connect("_load_data",Callable(gm,"_load_node"))
		if !gm.sn.has(str(get_path())):
			emit_signal("save_data_changed",save_data())
		else:
			emit_signal("_load_data",self,str(get_path()))
		#for n in neighbors:
			#var l=Line2D.new()
			#l.width=2
			#l.add_point(size/2)
			#l.add_point((n.global_position-global_position+size)/2)
			#$lines.add_child(l)
	img_think()
	
func _draw():
	for n in neighbors:
		if is_instance_valid(n):
			draw_line(size/2,(n.global_position-global_position+size)/2,Color.LIGHT_SLATE_GRAY,2)
func _process(delta):
	queue_redraw()
	if !$btn.disabled:
		$arena.self_modulate=Color(original.r*active,original.g*active,original.b*active)
	else:
		$arena.self_modulate=Color(original.r*unactive,original.g*unactive,original.b*unactive)
	$visual.self_modulate=Color(original.r*active,original.g*active,original.b*active)

	if last_runned!=runned:
		if !Engine.is_editor_hint():
			emit_signal("runned_changed",runned)
		last_runned=runned
		img_think()
	if last_player_here!=player_here:
		img_think()
		last_player_here=player_here
	if shop!= null and !shop_changed:
		img_think()
		shop_changed=true
	if shop==null and shop_changed:
		img_think()
		shop_changed=false
	if arena!= null and !arena_changed:
		img_think()
		arena_changed=true
	if arena==null and arena_changed:
		img_think()
		arena_changed=false
	
var shop_changed:bool=false
var arena_changed:bool=false
func set_pnl_pos():
	var pnl_glb_size=Vector2(place_panel_node.size.x,place_panel_node.size.y)*place_panel_node.scale
	var p_pos=global_position-Vector2(pnl_glb_size.x/2,pnl_glb_size.y)+Vector2(size.x/2,-size.y/2)
	place_panel_node.global_position=p_pos
func _on_button_down():
	place_panel_node.clean()
	if !runned:
		place_panel_node.visible=!place_panel_node.visible
		if arena!=null:
			if place_panel_node.visible:
				for e in ingame_statuses:
					if e!=null and e.status!="":
						place_panel_node.add_item(load(gm.objs.stats[e.status].i),tr(gm.objs.stats[e.status].ct),e.value,gm.objs.stats[e.status].postfix)
				set_pnl_pos()
				place_panel_node.connect_to(self,"play","cancel")
			else:
				if place_panel_node.visible:
					place_panel_node.disconnect_from(self,"play","cancel")
		elif shop!=null:
			set_pnl_pos()
			place_panel_node.visible=true
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
			map.shop_items.merge({self:{"":0}})
		else:
			runned=true
	else:
		if shop!=null:
			place_panel_node.visible=!place_panel_node.visible
			set_pnl_pos()
			place_panel_node.visible=true
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
			map.shop_items.merge({self:{"":0}})
func to_shop():
	place_panel_node.visible=false
	map.emit_signal("in_shop")
func play():
	print("lvl: ",level)
	var level_container=map.level_container
	if level_container!=null and level!="":
		
		lvl=load(level).instantiate()
		lvl.cam=get_tree().current_scene.get_node("cam")
		lvl.time=level_time
		lvl.enemys_data=arena
		lvl.enemy_path=get_tree().current_scene.enemy_path
		lvl.completed.connect(Callable(map,"level_completed").bind(self))
		map.emit_signal("location_added",lvl)
		level_container.add_child(lvl)
		level_container.move_child(lvl,0)
		gm.player_data.in_action=str(get_path())
		gm.save_file_data()
	else:
		runned=true
	cancel()
func cancel():
	place_panel_node.disconnect_from(self,"play","cancel")
	place_panel_node.hide()
func shop_cancel():
	place_panel_node.disconnect_from(self,"to_shop","shop_cancel")
	place_panel_node.hide()

func _on_runned_changed(res:bool):
	if res:gm.player_data.runned_lvls+=1
