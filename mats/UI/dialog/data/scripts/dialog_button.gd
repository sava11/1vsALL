class_name dialog_button extends Resource
@export var dialog_icon=Texture2D
@export var name:String="button_name"
@export var color:Color=Color(1,1,1)
@export var disabled:bool=false
@export_file("*.tres") var dialog_data_path
@export_group("function","function")
@export_node_path("Node") var function_node_path
@export var function_name:String
@export var function_arguments:Array=[]
