extends Node

var is_authority:bool

var lobby_ui_ref

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
	pass

func ServerDisconnected():
	multiplayer.multiplayer_peer=null
	UImanager.SwitchUI("MainMenu")
	pass

func NewPeerConnected(peer:int):
	if(is_authority):
		lobby_ui_ref.AddPlayer(peer)
	pass

func PeerDisconnected(peer:int):
	if(is_authority):
		lobby_ui_ref.RemovePlayer(peer)
	pass

func LobbyDataSync(val:String, id:int):
	if(is_authority):
		rpc("RecLobbyDataSync", val, id)
	else:
		rpc_id(1, "SendLobbyDataSync", val, id)
	pass


@rpc("any_peer", "reliable")
func SendLobbyDataSync(val:String, id:int):
	if(id==0 && id==1):
		return
	
	lobby_ui_ref.UpdatePlayerData(multiplayer.get_remote_sender_id(), str(val), id)
	if(id==4):
		SetPlayerList()

func SetPlayerList():
	if(is_authority):
		rpc("SetShortPlayerList", lobby_ui_ref.GetShortPlayerList())

@rpc("authority", "reliable")
func SetShortPlayerList(list:Array):
	lobby_ui_ref.UpdatePlayerList(list)

@rpc("authority", "reliable")
func RecLobbyDataSync(val:String, id:int):
	
	pass

func LobbyUpdate(dat:Dictionary):
	rpc("UpdateLobbyData", dat)


@rpc("authority", "reliable")
func UpdateLobbyData(dat:Dictionary):
	lobby_ui_ref.DisplayData(dat)
