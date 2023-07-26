extends Panel
var dvec:Vector2=Vector2.ZERO

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		show()

func _on_panel_gui_input(_event):
	if Input.is_action_just_pressed("lmb"):
		dvec=position-get_global_mouse_position()
	if Input.is_action_pressed("lmb"):
		global_position=dvec+get_global_mouse_position()

func _on_close_button_down():
	hide()
