extends Node2D


func Init(start:Vector2, end:Vector2):
	$"Trace Line".points[0]=start
	$"Trace Line".points[1]=end

func LifetimeEnd():
	get_parent().remove_child(self)
	queue_free()
	pass # Replace with function body.
