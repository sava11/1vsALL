extends HBoxContainer
@export var view:=false
@onready var img=$img
@onready var iname=$item_name
@onready var vle=$value
@export var item_name:String
@export_flags("greater:1","less:2") var value_type
@export var min_value=0
@export var max_value=0
@export var value=0
func _ready():
	if view: 
		iname.size_flags_horizontal=1
		img.size_flags_horizontal=2
func set_image(texture:Texture2D):
	img.texture=texture
func set_item_name(value:String="item"):
	iname.text=value
func set_value(v:float,prefix:String=""):
	if (v<min_value or v>max_value) and value_type==0:
		if v<min_value:
			v=min_value
		if v>max_value:
			v=max_value
	if prefix=="%":
		value=v
		vle.text=str(value*100)+" "+prefix
	else:
		vle.text=str(v)+prefix
		value=v
