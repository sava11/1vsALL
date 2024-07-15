extends TextureRect
@export var item_name:String=""
var value:=0
var lvl:=0
var stats:Dictionary
var del_name:String
func _ready():
	load_item(item_name)
# Called when the node enters the scene tree for the first time.
func load_item(item_name:String):
	var data=gm.objs.updates[item_name].duplicate(true)
	#match lvl:
		#0:get("theme_override_styles/panel").bg_color=Color(0,0,0,0.5)
		#1:get("theme_override_styles/panel").bg_color=Color(0,0,0.5,0.5)
		#2:get("theme_override_styles/panel").bg_color=Color(0,0.5,0,0.5)
		#2:get("theme_override_styles/panel").bg_color=Color(0.5,0,0.5,0.5)
		#3:get("theme_override_styles/panel").bg_color=Color(0,0.5,0.5,0.5)
		#4:get("theme_override_styles/panel").bg_color=Color(0.6,0.5,0,0.5)
	#data.merge({n:v},true)
	$whatIs.texture=load(data.i)
	$txt.text=tr(data.t)
	$value.text=str(value)
	
	for e in stats.keys():
		var item=preload("res://mats/UI/map/status_item/item.tscn").instantiate()
		item.item_name=e
		item.view=true
		$cont/cnt.add_child(item)
		item.set_image(load(gm.objs.stats[e].i))
		item.set_item_name(tr(gm.objs.stats[e].ct))
		item.set_value(stats[e],gm.objs.stats[e].postfix)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$buy.disabled=!gm.player_data.stats.money>=value

func _on_button_down():
	gm.player_data.stats.money-=value
	var temp_d={}
	for e in stats.keys():
		temp_d.merge({e:stats[e]})
	gm.merge_stats(temp_d)
	get_parent().get_parent().get_parent().upd_by_sts()
	get_parent().get_parent().get_parent().shop_items[get_parent().get_parent().get_parent().current_pos].erase(del_name)
	queue_free()
	pass # Replace with function body.
