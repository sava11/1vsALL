class_name shop_item extends Resource
@export var img:Texture
@export var item_scene:PackedScene
@export var self_name:String
@export_range(0,99,1,"or_greater") var lvl:int
@export_multiline var desc:String
var statuses:Dictionary
