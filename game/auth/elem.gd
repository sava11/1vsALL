extends Control
@export var nms:Array[auth_font]
@export_range(0,999) var spl:int=4
@export_range(0,999) var up_padding:int
func _ready():
	for e in nms:
		var l
		if e.link!="":
			l=LinkButton.new()
		else:
			l=Label.new()
		l.text=tr(e.text)
		l.self_modulate=e.clr
		if e.fnt!=null:
			l.set("theme_override_fonts/font",e.fnt)
		add_child(l)
		l.size.x=l.get_theme_font("font").get_string_size(l.text).x
		custom_minimum_size.x=max(custom_minimum_size.x,l.size.x)
		l.position.x=-l.size.x/2+size.x/2-4
		l.position.y=(l.get_index()-1)*(l.size.y+spl)+spl+l.size.y+up_padding
		custom_minimum_size.y=(l.get_index()-1)*(l.size.y+spl)+spl+l.size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
