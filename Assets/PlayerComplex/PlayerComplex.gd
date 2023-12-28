extends Node2D

class_name PlayerSubsys

@export var t_map:TileMap

var pl_ref

func _ready():
	pl_ref=$Player
	

func _process(delta):
	$LitView/Liter/TileMap.visible=false
	$LitView/Liter/TileMap.visible=true

func Preload(id_abil:int, team:int):
	var ref_map=$LitView/Liter/TileMap
	var ref2_map=$HidePort/HiddenOBJs/TileMap2
	var point_light_2d = $LitView/Liter/PointLight2D
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
			ref_map.set_pattern(2, Vector2i(i, g), t_map.get_pattern(2, [Vector2i(i, g)]))
			ref2_map.set_pattern(2, Vector2i(i, g), t_map.get_pattern(2, [Vector2i(i, g)]))
	$ViewComponent/Camera2D2.enabled=true
	
	pl_ref.InitGame(id_abil, team)
	

func AddHideNode(new_node:Node):
	$HidePort/HiddenOBJs.add_child(new_node)

func RemoveHideNode(old_node:Node):
	$HidePort/HiddenOBJs.remove_child(old_node)
	old_node.queue_free()


func UpdatePos(pos:Vector2):
	var sz=$HidePort.get_visible_rect().size
	$LitView/Liter.position=-pos+Vector2(sz.x/2, sz.y/2)
	$HidePort/HiddenOBJs.position=-pos+Vector2(sz.x/2, sz.y/2)
	$ViewComponent.position=pos
	$LitView/Liter/PointLight2D.position=pos
	
	pass



func SwitchPlayer(id:int, flg:bool):
	var id_tree="player#"+str(id)
	if (multiplayer.get_unique_id()==id):
		pl_ref.net_id=id
		pl_ref.net_id=id
		pl_ref.net_id=id
		pl_ref.name=id_tree
		visible=flg
		pl_ref.disabled=!flg
		Gameplay.player_ref["player#"+str(id)]=pl_ref

const rot_const=-PI/2
func SetLitRot(rot:float):
	$LitView/Liter/PointLight2D.rotation=rot+rot_const

