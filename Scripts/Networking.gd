extends Node

var is_authority:bool

var lobby_ui_ref

var ping_await={}

#### NETWORK PROCESS

func _ready():
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
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer

func Leave():
	multiplayer.multiplayer_peer=null
	pass

func ConnectedToServer():
	UImanager.SwitchUI("Lobby")
	Ping(1)
	pass

func ServerDisconnected():
	multiplayer.multiplayer_peer=null
	UImanager.SwitchUI("MainMenu")
	Gameplay.ClearAll()
	pass

func NewPeerConnected(peer:int):
	if(is_authority):
		lobby_ui_ref.AddPlayer(peer)
		PlayerData.RegisterStamp(peer, Time.get_ticks_msec())
		PlayerData.pings[peer]=0
		Ping(peer)
	pass

func PeerDisconnected(peer:int):
	if(is_authority):
		if(lobby_ui_ref!=null):
			lobby_ui_ref.RemovePlayer(peer)
		PlayerData.RemoveStampData(peer)
		PlayerData.pings.erase(peer)
		Gameplay.RemovePlayer(peer)
	pass





##### PLAYER DATA SYNCER

func SyncPosPlayer(id:String, pos:Vector2, vel:Vector2, rot:float):
	if(is_authority):
		rpc("SetSyncPosPlayer", id, pos, vel, rot)
	else:
		rpc_id(1, "CallSyncPosPlayer", id, pos, vel, rot)


func SwitchPlayerAnim(id:String, id_anim:int):
	if(is_authority):
		Gameplay.SetAnim(id, id_anim)
		rpc("SetAnim", id, id_anim)
	else:
		rpc_id(1, "RequestSetAnim", id, id_anim)
		pass

@rpc("any_peer", "unreliable")
func RequestSetAnim(id:String, id_anim:int):
	if(id=="player#"+str(multiplayer.get_remote_sender_id())):
		Gameplay.SetAnim(id, id_anim)
		rpc("SetAnim", id, id_anim)


@rpc("authority", "unreliable")
func SetAnim(id:String, id_anim:int):
	Gameplay.SetAnim(id, id_anim)
	pass


@rpc("any_peer", "unreliable")
func CallSyncPosPlayer(id:String, pos:Vector2, vel:Vector2, rot:float):
	
	var delta=PlayerData.GetPlayerDeltatime(multiplayer.get_remote_sender_id(), Time.get_ticks_msec())
	if(delta==0):
		return
	Gameplay.SyncPuppet(id, pos, vel, rot, delta)
	rpc("SetSyncPosPlayer", id, pos, vel, rot)
	
	pass

@rpc("authority", "unreliable")
func SetSyncPosPlayer(id:String, pos:Vector2, vel:Vector2, rot:float):
	Gameplay.SyncPuppet(id, pos, vel, rot, 0)

### SERVER PROCESSING


func Kick(id:int, reason:String):
	pass


func StartGame(map_data:String, player_in_lobby:Dictionary):
	rpc("StartGameSignal",map_data, player_in_lobby)

@rpc("authority", "reliable")
func StartGameSignal(map_data:String, player_in_lobby:Dictionary):
	Gameplay.StartGame(map_data, player_in_lobby)


######LOBBY DATA TRANSMISSION

func LobbyDataSync(val:String, id:int):
	if(is_authority):
		rpc("RecLobbyDataSync", val, id)
	else:
		rpc_id(1, "SendLobbyDataSync", val, id)
	pass


func SetPlayerList():
	if(is_authority):
		rpc("SetShortPlayerList", lobby_ui_ref.GetShortPlayerList())



func LobbyUpdate(dat:Dictionary):
	rpc("UpdateLobbyData", dat)

@rpc("any_peer", "reliable")
func SendLobbyDataSync(val:String, id:int):
	if(id==0 && id==1):
		return
	
	lobby_ui_ref.UpdatePlayerData(multiplayer.get_remote_sender_id(), str(val), id)
	if(id==4):
		SetPlayerList()



@rpc("authority", "reliable")
func SetShortPlayerList(list:Array):
	lobby_ui_ref.UpdatePlayerList(list)

@rpc("authority", "reliable")
func RecLobbyDataSync(val:String, id:int):
	
	pass


@rpc("authority", "reliable")
func UpdateLobbyData(dat:Dictionary):
	lobby_ui_ref.DisplayData(dat)



########PING

func MassPing():
	for i in PlayerData.pings.keys():
		Ping(i)


func Ping(id:int):
	ping_await[id]=Time.get_ticks_msec()
	rpc_id(id, "PingInit")
	pass

@rpc("any_peer", "reliable")
func PingInit():
	rpc_id(multiplayer.get_remote_sender_id(), "PingAns")
	pass

@rpc("any_peer", "reliable")
func PingAns():
	var id=multiplayer.get_remote_sender_id()
	PlayerData.pings[id]=Time.get_ticks_msec()-ping_await[id]
	ping_await.erase(id)
	pass


