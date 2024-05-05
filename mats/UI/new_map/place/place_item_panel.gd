extends Panel
func connect_to(n:Node,play:String,cancel:String):
	for e in $btns/play.get_signal_connection_list("button_down"):
		$btns/play.disconnect("button_down",e.callable)
	for e in $btns/cancel.get_signal_connection_list("button_down"):
		$btns/cancel.disconnect("button_down",e.callable)
	$btns/cancel.button_down.connect(Callable(n,cancel))
	$btns/play.button_down.connect(Callable(n,play))
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
	for e in $ScrollContainer/cont.get_children():
		e.queue_free()
func _process(delta):
	if !fnc.in_area($p.polygon,$p.get_local_mouse_position()) and visible:
		clean()
		hide()
func add_item(img:Texture2D,iname:String,value:float,value_suffix:String=""):
	var itm=preload("res://mats/UI/new_map/item/item.tscn").instantiate()
	itm.value_type=3
	$ScrollContainer/cont.add_child(itm)
	itm.set_image(img)
	itm.set_item_name(iname)
	itm.set_value(value,value_suffix)
