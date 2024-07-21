class_name shop_item extends Resource
@export var img:Texture
@export var self_name:String
@export_range(0,99,0.001,"or_greater") var rarity:float
@export_multiline var desc:String
@export var statuses:Array[ingame_status]
