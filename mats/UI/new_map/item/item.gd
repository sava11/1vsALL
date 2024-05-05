extends HBoxContainer
@export var only_value:=false
@onready var img=$img
@onready var iname=$item_name
@onready var vle=$value
@export_flags("greater:1","less:2") var value_type
@export var min_value=0
@export var max_value=0
@export var value=0
func _ready():
	if only_value: iname.hide()
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
		vle.text=str(v)+" "+prefix
		value=v/100
	else:
		vle.text=str(v)+prefix
		value=v
