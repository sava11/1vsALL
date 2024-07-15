extends Control
signal dialog_ended(dialog:String)
signal dialog_started(dialog:String)
@onready var btn_cont=$Panel/hbc/sc/vbc
var dialog:dialog_data=null
var tree_real_pause:=false
func _ready():
	clean_dialog()
	
func start(d:dialog_data):
	await get_tree().process_frame
	clean_dialog()
	load_data(d)
func load_data(d:dialog_data):
	if d!=null:
		emit_signal("dialog_started",d.name)
		if d.interactive:
			mouse_filter=Control.MOUSE_FILTER_IGNORE
		else:
			mouse_filter=Control.MOUSE_FILTER_STOP
		for e in btn_cont.get_children():
			e.queue_free()
		dialog=d
		if d.left_char_img!=$charL.texture:
			$charL.texture=d.left_char_img

		if d.right_char_img!=$charR.texture:
			$charR.texture=d.right_char_img
		if d.right_speeking:
			$charR/ap.play("action")
		else:
			$charR/ap.play("back")
		if d.left_speeking:
			$charL/ap.play("action")
		else:
			$charL/ap.play("back")
		$Panel/hbc/txt.text=tr(d.BDI_text)
		if d.function_node_path!=null:
			var node=get_tree().current_scene.get_node_or_null(d.function_node_path)
			if node!=null:
				if d.function_arguments.is_empty():
					Callable(node,d.function_name).call()
				else:
					Callable(node,d.function_name).callv(d.function_arguments)
		
		
		var first_button=null
		for ep in d.buttons:
			if is_instance_valid(ep):
				var b=Button.new()
				b.disabled=ep.disabled
				if first_button==null:
					first_button=b
				b.icon=ep.dialog_icon
				b.expand_icon=true
				if d.function_node_path!=null:
					var node1=get_tree().current_scene.get_node_or_null(ep.function_node_path)
					if node1!=null:
						if d.function_arguments.is_empty():
							Callable(node1,ep.function_name).call()
						else:
							Callable(node1,ep.function_name).callv(ep.function_arguments)
				if ep.dialog_data_path!=null:
					b.button_down.connect(Callable(self,"load_data").bind(load(ep.dialog_data_path)))
				else:
					b.button_down.connect(Callable(self,"clean_dialog"))
					b.button_down.connect(Callable(self,"emit_signal").bind("dialog_ended",ep.name))
				b.icon_alignment=HORIZONTAL_ALIGNMENT_LEFT
				b.self_modulate=ep.color
				b.text=tr(ep.name)
				b.custom_minimum_size.y=18
				btn_cont.add_child(b)
		if len(d.buttons)>0 and first_button!=null:
			first_button.grab_focus()
			if len(d.buttons)>1:
				$Panel/hbc/sc.show()
			if len(d.buttons)==1:
				$Panel/hbc/sc.hide()
		if d.paused==0:
			tree_real_pause=get_tree().paused
		if d.paused==1:
			if get_tree().paused!=true:
				tree_real_pause=get_tree().paused
			get_tree().set_deferred("paused",true)
		if d.paused==2:
			if get_tree().paused!=false:
				tree_real_pause=get_tree().paused
			get_tree().set_deferred("paused",false)
func clean_dialog():
	dialog=null
	for e in btn_cont.get_children():
		e.queue_free()
	$charL.texture=null
	$charR.texture=null
	$Panel/hbc/txt.text=""
func end_dialog():
	get_tree().set_deferred("paused",tree_real_pause)
	if btn_cont.get_child_count()>0 and btn_cont.get_parent_control().visible==false:
		btn_cont.get_child(0).emit_signal("button_down")
	if btn_cont.get_child_count()==0 and dialog!=null:
		emit_signal("dialog_ended",dialog.name)
		clean_dialog()
		hide()
func _input(_e):
	if Input.is_action_just_pressed("accept") and dialog!=null:
		end_dialog()


func _on_panel_gui_input(_e):
	if Input.is_action_just_pressed("lmb"):
		end_dialog()
