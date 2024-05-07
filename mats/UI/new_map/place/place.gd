@tool
class_name place extends Control
@export_group("level")
@export var level:PackedScene
@export var level_time:float=45.0
@export_group("place")
@export var runned:bool=false
@export var local_difficulty_add_step:float=0
@export_subgroup("statuses")
@export var arena:arena_action
@export var shop:shop_action
@export_group("place")
@export var ingame_statuses:Array[ingame_status]
@export var neighbors:Array[place]
@export var place_panel_node:Panel
@export_group("colors")
@export var original:Color
@export var active:float=1
@export var unactive:float=1
var map:Node
var lvl:level_template
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
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
func _ready():
	
	map=get_node("../../../")
	map.connect("location_added",Callable(func(lvl):map.cur_loc=lvl))
	if !Engine.is_editor_hint():
		connect("save_data_changed",Callable(gm,"_save_node"))
		connect("_load_data",Callable(gm,"_load_node"))
		if !gm.sn.has(str(get_path())):
			emit_signal("save_data_changed",save_data())
		else:
			emit_signal("_load_data",self,str(get_path()))
		for n in neighbors:
			var l=Line2D.new()
			l.width=2
			l.add_point(size/2)
			l.add_point((n.global_position-global_position+size)/2)
			$lines.add_child(l)
func _draw():
	for n in neighbors:
		if is_instance_valid(n):
			draw_line(size/2,(n.global_position-global_position+size)/2,Color.WHITE,2)
func _process(delta):
	queue_redraw()
	if !$btn.disabled:
		$visual.self_modulate=Color(original.r*active,original.g*active,original.b*active)
	else:
		$visual.self_modulate=Color(original.r*unactive,original.g*unactive,original.b*unactive)
func _on_button_down():
	var p_pos=global_position-Vector2(place_panel_node.size.x/2,place_panel_node.size.y)*place_panel_node.scale+Vector2(size.x/2,-size.y/4)
	if !runned:
		if arena!=null:
			place_panel_node.visible=!place_panel_node.visible
			if place_panel_node.visible and !runned:
				place_panel_node.global_position=p_pos
				for e in ingame_statuses:
					place_panel_node.add_item(e.editable_status.image,e.editable_status.name,e.value,e.value_suffix)
				place_panel_node.connect_to(self,"play","cancel")
			else:
				if place_panel_node.visible:
					place_panel_node.disconnect_from(self,"play","cancel")
		elif shop!=null:
			place_panel_node.global_position=p_pos
			place_panel_node.visible=true
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
			map.shop_items.merge({self:{"":0}})
		else:
			runned=true
	else:
		if shop!=null:
			place_panel_node.global_position=p_pos
			place_panel_node.visible=true
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
			map.shop_items.merge({self:{"":0}})
func to_shop():
	place_panel_node.visible=false
	map.emit_signal("in_shop")
func play():
	var level_container=map.level_container
	if level_container!=null and level!=null:
		lvl=level.instantiate()
		lvl.cam=get_tree().current_scene.get_node("cam")
		lvl.time=level_time
		lvl.enemys_data=arena
		gm.player_data.in_action=true
		lvl.enemy_path=get_tree().current_scene.enemy_path
		lvl.completed.connect(Callable(map,"level_completed").bind(self))
		map.emit_signal("location_added",lvl)
		level_container.add_child(lvl)
		level_container.move_child(lvl,0)
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
