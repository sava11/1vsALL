class_name dialog_data extends Resource
@export var name:String="NEW_DATA"
@export_multiline var BDI_text:String
@export var buttons:Array[dialog_button]
@export var interactive:bool=false
@export var large_answers:bool=false
@export_group("function","function")
@export_node_path("Node") var function_node_path
@export var function_name:String
@export var function_arguments:Array=[]
@export_group("image","image")
@export var image_bg:Texture2D
@export_subgroup("left","left")
@export var left_char_img:Texture2D
@export var left_speeking:bool=false
@export_subgroup("right","right")
@export var right_char_img:Texture2D
@export var right_speeking:bool=false
@export_enum("Tree_based","Paused","Unpaused") var paused:=0
