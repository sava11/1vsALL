@tool
class_name place extends Control
@export var runned:bool=false
@export var local_difficulty_add_step:float=0
@onready var last_runned=runned
@export var level:PackedScene
@export var ingame_statuses:Array[ingame_status]
@export var neighbors:Array[place]
@export var place_statuses:Array[empty_node]
@export var place_panel_node:Panel
@export_group("colors")
@export var original:Color
@export var active:float=1
@export var unactive:float=1
signal runned_changed(r:bool)
var map:Node
var lvl:level_template
func save_data():
	return {
		"runned":runned
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
		for n in neighbors:
			var l=Line2D.new()
			l.width=2
			l.add_point(size/2)
			l.add_point((n.global_position-global_position+size)/2)
			$lines.add_child(l)
func _draw():
	if Engine.is_editor_hint():
		for n in neighbors:
			if is_instance_valid(n):
				draw_line(size/2,(n.global_position-global_position+size)/2,Color.WHITE,2)
func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		if last_runned!=runned:
			last_runned=runned
			emit_signal("runned_changed",runned)
	if !$btn.disabled:
		$visual.self_modulate=Color(original.r*active,original.g*active,original.b*active)
	else:
		$visual.self_modulate=Color(original.r*unactive,original.g*unactive,original.b*unactive)
func _on_button_down():
	var p_pos=global_position-Vector2(place_panel_node.size.x/2,place_panel_node.size.y)*place_panel_node.scale+Vector2(size.x/2,-size.y/4)
	if !runned:
		if place_statuses.any(Callable(func(x):return x is arena_action)):
			place_panel_node.visible=!place_panel_node.visible
			if place_panel_node.visible and !runned:
				place_panel_node.global_position=p_pos
				for e in ingame_statuses:
					place_panel_node.add_item(e.editable_status.image,e.editable_status.name,e.value,e.value_suffix)
				place_panel_node.connect_to(self,"play","cancel")
			else:
				if place_panel_node.visible:
					place_panel_node.disconnect_from(self,"play","cancel")
		elif place_statuses.any(Callable(func(x):return x is shop_action)):
			place_panel_node.global_position=p_pos
			place_panel_node.visible=true
			runned=true
			place_panel_node.connect_to(self,"to_shop","shop_cancel")
			map.shop_items.merge({self:{"":0}})
		else:
			runned=true
func to_shop():
	place_panel_node.visible=false
	map.emit_signal("in_shop")
	
func play():
	var level_container=map.level_container
	if level_container!=null and level!=null:
		lvl=level.instantiate()
		lvl.cam=get_tree().current_scene.get_node("cam")
		map.emit_signal("location_added",lvl)
		level_container.add_child(lvl)
		level_container.move_child(lvl,0)
	else:
		runned=true
	cancel()
func cancel():
	place_panel_node.disconnect_from(self,"play","cancel")
	place_panel_node.hide()
func shop_cancel():
	place_panel_node.disconnect_from(self,"to_shop","shop_cancel")
	place_panel_node.hide()
