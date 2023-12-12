extends HBoxContainer
@export var img:Texture
@export var img_size:Vector2=Vector2(0,0)
@export var txt:String
#@export var center_text:bool=true
@export var show_popup_text:bool=false
@export var ext_vis:bool=false
var text=null
@export var popup_text=""
var show_time:float=0.5
var showing_time:float=0
@onready var rt=$rt
# Called when the node enters the scene tree for the first time.
func _ready():
	$tr.texture=img
	if img_size<=Vector2.ZERO:
		img_size=img.get_size()#*1.4
	$tr.custom_minimum_size=img_size
	$tr.size=img_size
	rt.text=txt
	$ext.visible=ext_vis
	rt.custom_minimum_size.x=rt.get_theme_default_font().get_string_size(txt).x
	#if center_text:
	#	$delimetr.position.y=rt.get_theme_default_font().get_string_size(txt).y/2
	#	rt.position.y=rt.get_theme_default_font().get_string_size(txt).y/2
	#custom_minimum_size.x=rt.custom_minimum_size.x+rt.position.x
func _process(delta):
	if text!=null:
		if text.visible==false:
			showing_time+=delta
		if showing_time>=show_time:
			showing_time=0.0
			text.global_position=get_global_mouse_position()+Vector2(-8,-text.size.y/4)
			text.show()
		if !(Geometry2D.is_point_in_polygon(get_global_mouse_position(),PackedVector2Array([
			global_position,
			global_position+size*Vector2(1,0),
			global_position+size,
			global_position+size*Vector2(0,1),
		])) or Geometry2D.is_point_in_polygon(get_global_mouse_position(),PackedVector2Array([
			text.global_position,
			text.global_position+text.size*Vector2(1,0)*text.scale,
			text.global_position+text.size*text.scale,
			text.global_position+text.size*Vector2(0,1)*text.scale,
		]))
		):
			text.queue_free()
	if txt!=rt.text:
		rt.text=txt
		rt.custom_minimum_size.x=rt.get_theme_default_font().get_string_size(txt).x
		#custom_minimum_size.x=rt.custom_minimum_size.x+rt.position.x

func _on_mouse_entered():
	if show_popup_text==true:
		for e in get_tree().current_scene.get_node("cl/massanges").get_children():
			if e.scene_file_path=="res://mats/UI/text_panel.tscn":
				e.queue_free()
		if text==null:
			text=preload("res://mats/UI/text_panel.tscn").instantiate()
			#$tr.add_child(text)
			get_tree().current_scene.get_node("cl/massanges").add_child(text)
			text.get_child(0).text=popup_text
