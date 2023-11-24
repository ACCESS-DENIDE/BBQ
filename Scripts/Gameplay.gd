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
		
	
	
	
	AddPlayer(multiplayer.get_unique_id())
	Networking.lobby_ui_ref=null
	UImanager.SwitchUI("InGame")


func AddPlayer(id:int):
	var new_player=player_prel.instantiate()
	my_node_name="player#"+str(id)
	new_player.name=my_node_name
	new_player.net_id=id
	$".".add_child(new_player)
	pass

func RemovePlayer(id:int):
	var id_str="player#"+str(id)
	for i in $Entitys.get_children():
		if(i.name==id_str):
			$Entitys.remove_child(i)
			i.queue_free()

func AddPuppet(id:int):
	var new_puppet=pupppet_prel.instantiate()
	new_puppet.name="player#"+str(id)
	new_puppet.net_id=id
	$Entitys.add_child(new_puppet)
	pass

func SyncPuppet(id:String, new_pos:Vector2, vel:Vector2, rot:float, delta:float):
	for i in $Entitys.get_children():
		if(i.name==id):
			i.SyncFunc(new_pos, vel, delta, rot)


func OnPingTime():
	Networking.MassPing()
	pass # Replace with function body.


func SetAnim(id:String, id_anim:int):
	for i in $Entitys.get_children():
		if(i.name==id):
			i.SetAnim(id_anim)
	pass


func ClearAll():
	for i in $Entitys.get_children():
		$Entitys.remove_child(i)
		i.queue_free()
	for i in $Statics.get_children():
		$Statics.remove_child(i)
		i.queue_free()
	for i in get_children():
		if(i.name==my_node_name):
			remove_child(i)
			i.queue_free()
