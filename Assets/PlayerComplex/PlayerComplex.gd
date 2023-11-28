extends Node2D

@export var t_map:TileMap
@export var t_size:int
@export var t_origin:int


# Called when the node enters the scene tree for the first time.
#t_map=$TileMap
#	
#	var beg:int=-6
#	var size:int=12
#	
#	for i in range (beg, beg+size):
#		for g in range (beg, beg+size):
#			var pattern=t_map.get_pattern(0, [Vector2i(i,g)])
#			$TileMap2.set_pattern(0, Vector2i(i,g), pattern)

func _ready():
	var ref_map=$LitView/Liter/TileMap
	var ref2_map=$HidePort/HiddenOBJs/TileMap2
	var point_light_2d = $LitView/Liter/PointLight2D
	#ref_map.position=Vector2(abs(t_origin)*32,abs(t_origin)*32)
	var sz=$HidePort.get_visible_rect().size
	$HidePort/HiddenOBJs.position=Vector2(sz.x/2, sz.y/2)
	$LitView/Liter.position=Vector2(sz.x/2, sz.y/2)
	for i in range(t_origin, t_size):
		for g in range(t_origin, t_size):
			ref_map.set_pattern(0, Vector2i(i, g), t_map.get_pattern(0, [Vector2i(i, g)]))
			ref2_map.set_pattern(0, Vector2i(i, g), t_map.get_pattern(0, [Vector2i(i, g)]))
	
	
	pass # Replace with function body.



func UpdatePos(pos:Vector2):
	var sz=$HidePort.get_visible_rect().size
	$LitView/Liter.position=-pos+Vector2(sz.x/2, sz.y/2)
	$HidePort/HiddenOBJs.position=-pos+Vector2(sz.x/2, sz.y/2)
	print(str($LitView/Liter.position))
	pass

const rot_const=-90
func SetLitRot(rot:float):
	$LitView/Liter/PointLight2D.rotation=rot+rot_const

