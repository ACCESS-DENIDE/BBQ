extends Node2D

var player_prel=preload("res://Assets/Player/Player.tscn")
var pupppet_prel=preload("res://Assets/PlayerPuppet/PlayerPuppet.tscn")

var my_node_name:String=""
var map_size:Vector2i=Vector2i(0,0)

var is_started:bool=false

var player_ref={}

var player_spawners=[]

var b_base_ref=null
var r_base_ref=null

var spawner_thread:Thread

var item_spawners=[]
var active_items=0
var gameplay_spawners=[]

var prop_spawners=[]
var active_props=0

var player_inf:Dictionary

var map_store:Dictionary

func StartGameClient(map_data:Dictionary, player_in_lobby:Dictionary):
	var my_net_id=multiplayer.get_unique_id()
	DrawMapTiles(map_data)
	
	Networking.lobby_ui_ref=null
	UImanager.SwitchUI("InGame")
	$Map.visible=true
	AddPlayer(multiplayer.get_unique_id())
	$PlayerComplex.Preload(player_in_lobby[multiplayer.get_unique_id()]["power"], player_in_lobby[my_net_id]["team"])
	
	
	
	for i in player_in_lobby.keys():
		if(i!=my_net_id):
			AddPuppet(i, -1, player_in_lobby[i]["team"])

func StartGameServer(map_path:String, player_in_lobby:Dictionary):
	is_started=true
	active_items=0
	active_props=0
	b_base_ref=null
	player_inf=player_in_lobby
	var r_base_ref=null
	if(Networking.is_authority):
		GamemodeProcessor.AssignTeams(player_in_lobby)
		var Loader=FileAccess.open("Maps/"+map_path, FileAccess.READ)
		var map_data=JSON.parse_string(Loader.get_as_text())
		
		var shift_coord:Vector2i=(str_to_var("Vector2i"+map_data["Shift"]))
		
		var spawner_data=map_data["SpawnerData"]
		
		var new_spawner_data={}
		
		for i in spawner_data.keys():
			var old_x:int
			var old_y:int
			old_x=int(i.split(":")[0])
			old_y=int(i.split(":")[1])
			new_spawner_data[str(old_x-shift_coord.x)+":"+str(old_y-shift_coord.y)]=spawner_data[i]
	
		
		map_store=map_data
		
		Networking.StartGame(map_data["Map"], player_in_lobby)
		DrawMapTiles(map_data["Map"])
		
		pass
	
	
	
	
	Networking.lobby_ui_ref=null
	UImanager.SwitchUI("InGame")
	$Map.visible=true
	AddPlayer(multiplayer.get_unique_id())
	$PlayerComplex.Preload(player_in_lobby[1]["power"], player_in_lobby[1]["team"])
	
	for i in player_in_lobby.keys():
		if(i!=1):
			AddPuppet(i, player_in_lobby[i]["power"], player_in_lobby[i]["team"])


func DrawMapTiles(tile_data:Dictionary):
	var map_ref:TileMap=$Map
	for i in tile_data.keys():
		var unstringed:Vector3i=Vector3i(int(i.split(":")[0]), int(i.split(":")[1]), int(i.split(":")[2]))
		var layer:int=unstringed.z
		var cord:Vector2i=Vector2i(unstringed.x, unstringed.y)
		var tile:Vector3i=Vector3i(str_to_var("Vector3i"+tile_data[i]))
		
		match layer:
			0:
				map_ref.set_cell(0, cord, 0, Vector2i(tile.x, tile.y), tile.z)
				pass
			1:
				map_ref.set_cell(1, cord, 1, Vector2i(tile.x, tile.y), tile.z)
				pass
			2:
				
				if(Vector2i(tile.x, tile.y)==Vector2i(2,0)):
					map_ref.set_cell(2, cord, 2, Vector2i(tile.x, tile.y), tile.z)
					if(b_base_ref==null):
						map_ref.set_cell(2, cord, 2, Vector2i(tile.x, tile.y), 1)
						b_base_ref=unstringed
					else:
						map_ref.set_cell(2, cord, 2, Vector2i(tile.x, tile.y), 2)
						
						r_base_ref=unstringed
		
		if(map_size.x<cord.x):
			map_size.x=cord.x
		if(map_size.y<cord.y):
			map_size.y=cord.y
	
	pass

func AddPlayer(id:int):
	player_ref["player#"+str(id)]=$PlayerComplex.pl_ref
	$PlayerComplex.SwitchPlayer(id, true)
	pass

func RemovePlayer(id:int):
	$PlayerComplex.SwitchPlayer(id, false)
	pass

func AddPuppet(id:int, id_abil:int, team:int):
	var new_puppet=pupppet_prel.instantiate()
	new_puppet.name="player#"+str(id)
	new_puppet.net_id=id
	$PlayerComplex.AddHideNode(new_puppet)
	new_puppet.InitGame(id_abil, team)
	player_ref["player#"+str(id)]=new_puppet
	pass

func RemovePuppet(id:int):
	var id_tree="player#"+str(id)
	if(player_ref.has(id_tree)):
		var ref=player_ref[id_tree]
		ref.get_parent().remove_child(ref)
		ref.queue_free()
		player_ref.erase(id_tree)

func SyncPuppet(id:String, new_pos:Vector2, vel:Vector2, rot:float, delta:float, syncid:int):
	if(!((Networking.is_data_loaded) && (is_started))):
		return
	player_ref[id].SyncFunc(new_pos, vel, delta, rot, syncid)

func OnPingTime():
	Networking.MassPing()
	pass # Replace with function body.


func SetAnim(id:String, id_anim:int):
	if(!((Networking.is_data_loaded) && (is_started))):
		return
	player_ref[id].SetAnim(id_anim)
	pass

func SwitchTeam(id:String, id_team:int):
	if(!(Networking.is_data_loaded)):
		return
	player_ref[id].SwitchTeam(id_team)
	pass

func ClearAll():
	$Map.visible=false
	$PlayerComplex.visible=false
	pass


func EnableUI(ref:Node):
		for i in get_children():
			if(i.name==my_node_name):
				i.SetUI(ref)
