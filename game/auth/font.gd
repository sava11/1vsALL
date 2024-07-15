class_name auth_font extends Resource
@export var text:String
@export var link:String
@export var fnt:FontVariation
@export var clr:=Color(1,1,1)
func _init():
	if fnt==null:
		fnt=FontVariation.new()
		fnt.base_font=preload("res://mats/UI/font/Puzzle-Tale-Pixel-Regular.ttf")
