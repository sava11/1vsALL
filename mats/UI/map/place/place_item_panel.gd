class_name status_panel extends MarginContainer
@export var cur_place:place

func connect_to(n:place,play:String,cancel:String):
	for e in $mc/cont/btns/play.get_signal_connection_list("button_down"):
		$mc/cont/btns/play.disconnect("button_down",e.callable)
	for e in $mc/cont/btns/cancel.get_signal_connection_list("button_down"):
		$mc/cont/btns/cancel.disconnect("button_down",e.callable)
	$mc/cont/btns/cancel.button_down.connect(Callable(n,cancel))
	$mc/cont/btns/play.button_down.connect(Callable(n,play))
	cur_place=n
	#print($mc/cont/btns/play.get_signal_connection_list("button_down"))
func disconnect_from(n:Node,play:String,cancel:String):
	$mc/cont/btns/cancel.button_down.disconnect(Callable(n,cancel))
	$mc/cont/btns/play.button_down.disconnect(Callable(n,play))
	clean()
func clean():
	for e in $mc/cont/btns/play.get_signal_connection_list("button_down"):
		$mc/cont/btns/play.disconnect("button_down",e.callable)
	for e in $mc/cont/btns/cancel.get_signal_connection_list("button_down"):
		$mc/cont/btns/cancel.disconnect("button_down",e.callable)
	for e in $mc/cont/stats.get_children():
		e.free()
	size.y=0
	cur_place=null
#func _process(delta):
	#if !fnc.in_area($p.polygon,$p.get_local_mouse_position()) and visible:
		#clean()
		#hide()
var in_:=false
func add_item(img:Texture2D,iname:String,value:float,value_suffix:String=""):
	var itm=preload("res://mats/UI/map/status_item/item.tscn").instantiate()
	itm.value_type=3
	itm.view=true
	$mc/cont/stats.add_child(itm)
	itm.set_image(img)
	itm.set_item_name(iname)
	itm.set_value(value,value_suffix)
	#position.y-=(itm.size.y*scale.y)
