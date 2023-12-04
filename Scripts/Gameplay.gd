extends Node2D

var player_prel=preload("res://Assets/Player/Player.tscn")
var pupppet_prel=preload("res://Assets/PlayerPuppet/PlayerPuppet.tscn")

var my_node_name:String=""

func StartGame(map_path:String, player_in_lobby:Dictionary):
	
	if(Networking.is_authority):
		var map_string:String=""
		
		
		
		Networking.StartGame(map_string, player_in_lobby)
		pass
	else:
		
		
		pass
	
	
	player_in_lobby.erase(multiplayer.get_unique_id())
	
	for i in player_in_lobby.keys():
		AddPuppet(i)
		
	
	$Map.visible=true
	$PlayerComplex.Preload()
	AddPlayer(multiplayer.get_unique_id())
	Networking.lobby_ui_ref=null
	UImanager.SwitchUI("InGame")


func AddPlayer(id:int):
	$PlayerComplex.SwitchPlayer("player#"+str(id), true)
	pass

func RemovePlayer(id:int):
	$PlayerComplex.SwitchPlayer("player#"+str(id), false)
	pass

func AddPuppet(id:int):
	var new_puppet=pupppet_prel.instantiate()
	new_puppet.name="player#"+str(id)
	new_puppet.net_id=id
	$PlayerComplex.AddHideNode(new_puppet)
	pass

func SyncPuppet(id:String, new_pos:Vector2, vel:Vector2, rot:float, delta:float):
	$PlayerComplex.SyncHiddenNode(id, new_pos, vel, rot, delta)


func OnPingTime():
	Networking.MassPing()
	pass # Replace with function body.


func SetAnim(id:String, id_anim:int):
	$PlayerComplex.SetAnim(id, id_anim)
	pass


func ClearAll():
	pass


func EnableUI(ref:Node):
		for i in get_children():
			if(i.name==my_node_name):
				i.SetUI(ref)
