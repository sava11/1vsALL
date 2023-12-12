extends TextureRect

func _process(delta):
	position.y-=20*delta
	pass

func _on_del_t_timeout():
	queue_free()
