extends Node

var is_authority:bool
var is_online:bool
var is_data_loaded:bool

var lobby_ui_ref

var ping_await={}

#### NETWORK PROCESS

func _ready():
	is_online=false
	multiplayer.connected_to_server.connect(ConnectedToServer)
	multiplayer.peer_connected.connect(NewPeerConnected)
	multiplayer.peer_disconnected.connect(PeerDisconnected)
	multiplayer.server_disconnected.connect(ServerDisconnected)

func ConnectTo(ip:String, port:int):
	is_authority=false
	if ip == "":
		OS.alert("Need a remote to connect to.")
		return
	if (port<1 || port>65535):
		OS.alert("Need a valid port to connect.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, int(port))
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	


func Host(port:int):
	is_authority=true
	is_online=true
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	is_data_loaded=true

func Leave():
	is_online=false
	multiplayer.multiplayer_peer=null
	pass

func ConnectedToServer():
	is_online=true
	UImanager.SwitchUI("Lobby")
	Ping(1)
	PlayerData.pings[1]=0
	pass

func ServerDisconnected():
	is_online=false
	multiplayer.multiplayer_peer=null
	UImanager.SwitchUI("MainMenu")
	Gameplay.ClearAll()
	pass

func NewPeerConnected(peer:int):
	if(is_authority):
		if(lobby_ui_ref!=null):
			lobby_ui_ref.AddPlayer(peer)
		PlayerData.RegisterStamp(peer)
		PlayerData.pings[peer]=0
		Ping(peer)
		PlayerData.pings[peer]=0
		if(Gameplay.is_started):
			SignalForcePlayerSpawn(peer, 0)
			RequestLocalValue(peer)
			
	pass

func PeerDisconnected(peer:int):
	if(is_authority):
		if(lobby_ui_ref!=null):
			lobby_ui_ref.RemovePlayer(peer)
		if(Gameplay.is_started):
			GamemodeProcessor.RemovePlayer("player#"+str(peer))
			Gameplay.RemovePuppet(peer)
		PlayerData.RemoveStampData(peer)
		PlayerData.pings.erase(peer)
		CallRemovePuppet(peer)
	pass





##### PLAYER DATA SYNCER

func CallRemovePuppet(id:int):
	
	rpc("RemovePuppet", id)

@rpc("authority", "reliable")
func RemovePuppet(id:int):
	Gameplay.RemovePuppet(id, )
	

func SignalForcePlayerSpawn(id:int, team:int):
	rpc("ForcePlayerSpawn", id, team)

@rpc("authority", "reliable")
func ForcePlayerSpawn(id:int, team:int):
	if(id==multiplayer.get_unique_id()):
		return
	
	Gameplay.AddPuppet(id, -1,team)
	

func DashPlayer(flg:bool):
	if(is_authority):
		var ref=Gameplay.player_ref["player#"+str(1)]
		ref.DashSwitch(flg)
		SyncSpeed(1, ref.base_speed, ref.speed)
	else:
		var ref=Gameplay.player_ref["player#"+str(multiplayer.get_unique_id())]
		ref.DashSwitch(flg)
		rpc_id(1, "SetDashPlayer", flg)

@rpc("any_peer", "reliable")
func SetDashPlayer(flg:bool):
	var ref=Gameplay.player_ref["player#"+str(multiplayer.get_remote_sender_id())]
	ref.DashSwitch(flg)
	SyncSpeed(multiplayer.get_remote_sender_id(), ref.base_speed, ref.speed)

func RequestLocalValue(id_sourse:int):
	rpc_id(id_sourse, "CallRequestLocalValue", Gameplay.map_store["Map"], Gameplay.player_inf)
	for i in Gameplay.player_ref.values():
		rpc_id(id_sourse, "GetSyncSpeed", i.net_id, i.base_speed, i.speed)

@rpc("authority", "reliable")
func CallRequestLocalValue(map_tiles:Dictionary, players:Dictionary):
	var net_id=multiplayer.get_unique_id()
	rpc_id(1, "GetRequestLocalValue", GameLocalVar.default_abil, GameLocalVar.default_name)
	players[net_id]={}
	players[net_id]["display_name"]=GameLocalVar.default_name
	players[net_id]["team"]=0
	players[net_id]["power"]=GameLocalVar.default_abil
	players[net_id]["ready"]=1
	StartGameSignal(map_tiles, players)


@rpc("any_peer", "reliable")
func GetRequestLocalValue(id_abil:int, def_name:String):
	var net_id=multiplayer.get_remote_sender_id()
	Gameplay.player_inf[net_id]={}
	Gameplay.player_inf[net_id]["display_name"]=def_name
	Gameplay.player_inf[net_id]["team"]=0
	Gameplay.player_inf[net_id]["power"]=id_abil
	Gameplay.player_inf[net_id]["ready"]=1
	GamemodeProcessor.AddPlayer(net_id, id_abil)
	SwitchPlayerTeam(net_id, Gameplay.player_inf[net_id]["team"])



func SyncSpeed(id:int, base:float, cur:float):
	if(is_authority):
		rpc("GetSyncSpeed", id, base, cur)


@rpc("authority", "reliable")
func GetSyncSpeed(id:int, base:float, cur:float):
	Gameplay.player_ref["player#"+str(id)].LoadSpeed(base, cur)

func SyncUiState(id:int, ui_id:int, val:Dictionary):
	if(id==1):
		UImanager.GetCurUI().UpdateInfo(ui_id, val)
	else:
		rpc_id(id, "GetUiSync", ui_id, val)
	pass
	pass

@rpc("authority", "reliable")
func GetUiSync(ui_id:int, val:Dictionary):
	UImanager.GetCurUI().UpdateInfo(ui_id, val)

func SwitchPlayerTeam(id:int, team_id:int):
	rpc("SwitchTeamSignal", id, team_id)

@rpc("authority", "reliable")
func SwitchTeamSignal(id:int, team_id:int):
	Gameplay.SwitchTeam("player#"+str(id), team_id)


func SyncPosPlayer(id:String, pos:Vector2, vel:Vector2, rot:float):
	if(!is_online):
		return
	if(is_authority):
		rpc("SetSyncPosPlayer", id, pos, vel, rot)
	else:
		rpc_id(1, "CallSyncPosPlayer", id, pos, vel, rot)


func SwitchPlayerAnim(id:String, id_anim:int):
	if(!is_online):
		return
	if(is_authority):
		Gameplay.SetAnim(id, id_anim)
		rpc("SetAnim", id, id_anim)
	else:
		rpc_id(1, "RequestSetAnim", id, id_anim)
		pass

@rpc("any_peer", "unreliable")
func RequestSetAnim(id:String, id_anim:int):
	if(!is_online):
		return
	if(id=="player#"+str(multiplayer.get_remote_sender_id())):
		Gameplay.SetAnim(id, id_anim)
		rpc("SetAnim", id, id_anim)


@rpc("authority", "unreliable")
func SetAnim(id:String, id_anim:int):
	if(!is_online):
		return
	Gameplay.SetAnim(id, id_anim)
	pass


@rpc("any_peer", "unreliable_ordered")
func CallSyncPosPlayer(id:String, pos:Vector2, vel:Vector2, rot:float):
	if(!is_online):
		return
	var delta=PlayerData.GetPlayerDeltatime(multiplayer.get_remote_sender_id())
	if(delta==0):
		return
	Gameplay.SyncPuppet(id, pos, vel, rot, delta)
	rpc("SetSyncPosPlayer", id, pos, vel, rot)
	
	pass

@rpc("authority", "unreliable")
func SetSyncPosPlayer(id:String, pos:Vector2, vel:Vector2, rot:float):
	if(!is_online):
		return
	Gameplay.SyncPuppet(id, pos, vel, rot, 0)

### SERVER PROCESSING


func Kick(id:int, reason:String):
	print("Player id <"+str(id)+"> was kicked, reason:" +reason)
	pass


func StartGame(map_data:Dictionary, player_in_lobby:Dictionary):
	if(!is_online):
		return
	rpc("StartGameSignal",map_data, player_in_lobby)

@rpc("authority", "reliable")
func StartGameSignal(map_data:Dictionary, player_in_lobby:Dictionary):
	if(!is_online):
		return
	Gameplay.StartGameClient(map_data, player_in_lobby)
	is_data_loaded=true


######LOBBY DATA TRANSMISSION

func RequestAction(action_id:int):
	rpc_id(1, "ExecuteAction", action_id, multiplayer.get_unique_id())

@rpc("any_peer", "reliable")
func ExecuteAction(action_id:int, sender_id:int):
	Gameplay.MakeAction("player#"+str(sender_id), action_id)
	pass

func LobbyDataSync(val:String, id:int):
	if(!is_online):
		return
	if(is_authority):
		rpc("RecLobbyDataSync", val, id)
	else:
		rpc_id(1, "SendLobbyDataSync", val, id)
	pass


func SetPlayerList():
	if(!is_online):
		return
	if(is_authority):
		if(lobby_ui_ref==null):
			return
		rpc("SetShortPlayerList", lobby_ui_ref.GetShortPlayerList())



func LobbyUpdate(dat:Dictionary):
	if(!is_online):
		return
	rpc("UpdateLobbyData", dat)

@rpc("any_peer", "reliable")
func SendLobbyDataSync(val:String, id:int):
	if(!is_online):
		return
	if(id==0 || id==1):
		return
	if(lobby_ui_ref==null):
		return
	lobby_ui_ref.UpdatePlayerData(multiplayer.get_remote_sender_id(), str(val), id)
	SetPlayerList()



@rpc("authority", "reliable")
func SetShortPlayerList(list:Array):
	if(!is_online):
		return
	lobby_ui_ref.UpdatePlayerList(list)

@rpc("authority", "reliable")
func RecLobbyDataSync(val:String, id:int):
	if(!is_online):
		return
	pass


@rpc("authority", "reliable")
func UpdateLobbyData(dat:Dictionary):
	if(!is_online):
		return
	lobby_ui_ref.DisplayData(dat)



########PING

func MassPing():
	if(!is_online):
		return
	for i in PlayerData.pings.keys():
		Ping(i)


func Ping(id:int):
	if(!is_online):
		return
	ping_await[id]=Time.get_ticks_msec()
	rpc_id(id, "PingInit")
	pass

@rpc("any_peer", "reliable")
func PingInit():
	if(!is_online):
		return
	rpc_id(multiplayer.get_remote_sender_id(), "PingAns")
	pass

@rpc("any_peer", "reliable")
func PingAns():
	if(!is_online):
		return
	var id=multiplayer.get_remote_sender_id()
	PlayerData.pings[id]=Time.get_ticks_msec()-ping_await[id]
	ping_await.erase(id)
	pass


