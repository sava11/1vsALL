extends Panel
@export var cur_place:place

func connect_to(n:place,play:String,cancel:String):
	for e in $cont/btns/play.get_signal_connection_list("button_down"):
		$cont/btns/play.disconnect("button_down",e.callable)
	for e in $cont/btns/cancel.get_signal_connection_list("button_down"):
		$cont/btns/cancel.disconnect("button_down",e.callable)
	$cont/btns/cancel.button_down.connect(Callable(n,cancel))
	$cont/btns/play.button_down.connect(Callable(n,play))
	cur_place=n
	##print($cont/btns/play.get_signal_connection_list("button_down"))
func disconnect_from(n:Node,play:String,cancel:String):
	$cont/btns/cancel.button_down.disconnect(Callable(n,cancel))
	$cont/btns/play.button_down.disconnect(Callable(n,play))
	clean()
func clean():
	size.y=26
	for e in $cont/btns/play.get_signal_connection_list("button_down"):
		$cont/btns/play.disconnect("button_down",e.callable)
	for e in $cont/btns/cancel.get_signal_connection_list("button_down"):
		$cont/btns/cancel.disconnect("button_down",e.callable)
	for e in $cont/scont/cont.get_children():
		e.queue_free()
	cur_place=null
#func _process(delta):
	#if !fnc.in_area($p.polygon,$p.get_local_mouse_position()) and visible:
		#clean()
		#hide()
var in_:=false
func add_item(img:Texture2D,iname:String,value:float,value_suffix:String=""):
	var itm=preload("res://mats/UI/new_map/item/item.tscn").instantiate()
	itm.value_type=3
	itm.view=true
	$cont/scont/cont.add_child(itm)
	itm.set_image(img)
	itm.set_item_name(iname)
	itm.set_value(value,value_suffix)
	position.y-=(itm.size.y*scale.y)
	size.y=(itm.size.y*scale.y)*$cont/scont/cont.get_child_count()+26
