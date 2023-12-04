extends Node2D

@export var t_map:TileMap



func Preload():
	var ref_map=$LitView/Liter/TileMap
	var ref2_map=$HidePort/HiddenOBJs/TileMap2
	var point_light_2d = $LitView/Liter/PointLight2D
	pl_ref=$Player
	#ref_map.position=Vector2(abs(t_origin)*32,abs(t_origin)*32)
	var sz=$HidePort.get_visible_rect().size
	$HidePort/HiddenOBJs.position=Vector2(sz.x/2, sz.y/2)
	$LitView/Liter.position=Vector2(sz.x/2, sz.y/2)
	
	var t_origin=0
	var t_size=max(t_map.get_used_rect().size.x+1, t_map.get_used_rect().size.x+1)
	
	for i in range(t_origin, t_size):
		for g in range(t_origin, t_size):
			ref_map.set_pattern(0, Vector2i(i, g), t_map.get_pattern(0, [Vector2i(i, g)]))
			ref2_map.set_pattern(0, Vector2i(i, g), t_map.get_pattern(0, [Vector2i(i, g)]))
			ref_map.set_pattern(1, Vector2i(i, g), t_map.get_pattern(1, [Vector2i(i, g)]))
			ref2_map.set_pattern(1, Vector2i(i, g), t_map.get_pattern(1, [Vector2i(i, g)]))
	$ViewComponent/Camera2D2.enabled=true
	

func AddHideNode(new_node:Node):
	$HidePort/HiddenOBJs.add_child(new_node)

func RemoveHideNode(old_node:Node):
	$HidePort/HiddenOBJs.remove_child(old_node)
	old_node.queue_free()

func SyncHiddenNode(id:String, new_pos:Vector2, vel:Vector2, rot:float, delta:float):
	for i in $HidePort/HiddenOBJs.get_children():
		if(i.name==id):
			i.SyncFunc(new_pos, vel, delta, rot)

func SetAnim(id:String, id_anim:int):
	for i in $HidePort/HiddenOBJs.get_children():
		if(i.name==id):
			i.SetAnim(id_anim)

func UpdatePos(pos:Vector2):
	var sz=$HidePort.get_visible_rect().size
	$LitView/Liter.position=-pos+Vector2(sz.x/2, sz.y/2)
	$HidePort/HiddenOBJs.position=-pos+Vector2(sz.x/2, sz.y/2)
	$ViewComponent.position=pos
	$LitView/Liter/PointLight2D.position=pos
	pass

var pl_ref

func SwitchPlayer(id:String, flg:bool):
	pl_ref.name=id
	visible=flg
	pl_ref.disabled=!flg

const rot_const=-PI/2
func SetLitRot(rot:float):
	$LitView/Liter/PointLight2D.rotation=rot+rot_const

