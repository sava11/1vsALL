extends Panel
@export var cur_place:place
func connect_to(n:place,play:String,cancel:String):
	for e in $btns/play.get_signal_connection_list("button_down"):
		$btns/play.disconnect("button_down",e.callable)
	for e in $btns/cancel.get_signal_connection_list("button_down"):
		$btns/cancel.disconnect("button_down",e.callable)
	$btns/cancel.button_down.connect(Callable(n,cancel))
	$btns/play.button_down.connect(Callable(n,play))
	cur_place=n
	##print($btns/play.get_signal_connection_list("button_down"))
func disconnect_from(n:Node,play:String,cancel:String):
	$btns/cancel.button_down.disconnect(Callable(n,cancel))
	$btns/play.button_down.disconnect(Callable(n,play))
	clean()
func clean():
	for e in $btns/play.get_signal_connection_list("button_down"):
		$btns/play.disconnect("button_down",e.callable)
	for e in $btns/cancel.get_signal_connection_list("button_down"):
		$btns/cancel.disconnect("button_down",e.callable)
	for e in $scont/cont.get_children():
		e.queue_free()
	size.y=38
	cur_place=null
	hide()
#func _process(delta):
	#if !fnc.in_area($p.polygon,$p.get_local_mouse_position()) and visible:
		#clean()
		#hide()
var in_:=false
func add_item(img:Texture2D,iname:String,value:float,value_suffix:String=""):
	var itm=preload("res://mats/UI/new_map/item/item.tscn").instantiate()
	itm.value_type=3
	itm.view=true
	$scont/cont.add_child(itm)
	itm.set_image(img)
	itm.set_item_name(iname)
	itm.set_value(value,value_suffix)
	position.y-=itm.size.y/2
	size.y=(itm.size.y)*$scont/cont.get_child_count()+38
