extends Control

@onready var open_switch_gamemode = $Grid/SubGrid/Open_switch_gamemode
@onready var open_switch_map = $Grid/SubGrid/Open_switch_map

@onready var player_list = $Grid/PlayerList

@onready var gamemode_display = $Grid/SubGrid/Gamemode_display
@onready var map_display = $Grid/SubGrid/Map_display
@onready var team_display = $Grid/SubGrid/Team_display
@onready var ability_display = $Grid/SubGrid/Ability_display
@onready var ready_display = $Grid/SubGrid/Ready_display
@onready var ready_switch = $Grid/SubGrid/Ready_switch
@onready var ready_amount = $Grid/SubGrid/ReadyAmount

@onready var grid = $Grid


@onready var selection_list:ItemList = $Sellector/Selection_list
@onready var sellector = $Sellector

var player_in_lobby={}

var lobby_params={}
var map_id:int=-1

var display_name:String

var is_ready=false

var net_id:int=-1

var selector_pick:int=-1
var change_id:int=-1

var server_prop_loaded:bool=0


func _ready():
	net_id=multiplayer.get_unique_id()
	Networking.lobby_ui_ref=self
	if(Networking.is_authority):
		open_switch_gamemode.disabled=false
		open_switch_map.disabled=false
	else:
		open_switch_gamemode.disabled=true
		open_switch_map.disabled=true
	
	AddPlayer(net_id)
	
	if(!Networking.is_authority):
		pass
	else:
		GameGlobalVar.loaded_maps.clear()
		var direct:DirAccess=DirAccess.open("res://Maps")
	
		for i in direct.get_files():
			if(i.split(".")[1]=="bbq"):
				GameGlobalVar.loaded_maps[i.split(".")[0]]=i
		
		map_id=0
		lobby_params["GM"]=0
		lobby_params["Map"]=GameGlobalVar.loaded_maps.keys()[map_id]
		lobby_params["Ready"]="0/0"
		gamemode_display.text=GameGlobalVar.gamemodes[lobby_params["GM"]]
		map_display.text=lobby_params["Map"]
	
	
	
	team_display.text=GameGlobalVar.teams[player_in_lobby[net_id]["team"]]
	ability_display.text=GameGlobalVar.powers[player_in_lobby[net_id]["power"]]
	display_name=player_in_lobby[net_id]["display_name"]
	DisplayReady()
	$Grid/SubGrid/Text_name.text=display_name
	

func AddPlayer(peer_id:int):
	player_in_lobby[peer_id]={}
	player_in_lobby[peer_id]["display_name"]="PLACEHOLDER_NAME"
	player_in_lobby[peer_id]["team"]=0
	player_in_lobby[peer_id]["power"]=0
	player_in_lobby[peer_id]["ready"]=0
	CheckReady()
	MassUpdatePlayerList()

func MassUpdatePlayerList():
	UpdatePlayerList(GetShortPlayerList())
	Networking.SetPlayerList()

func UpdatePlayerList(arr:Array):
	player_list.clear()
	for i in arr:
		player_list.add_item(i)

func DisplayData(dat:Dictionary):
	
	gamemode_display.text=GameGlobalVar.gamemodes[dat["GM"]]
	map_display.text=dat["Map"]
	ready_amount.text=dat["Ready"]
	

func GetShortPlayerList()->Array:
	var arr=[]
	
	for i in player_in_lobby.values():
		arr.push_back(i["display_name"])
	
	return arr

func UpdatePlayerData(peer_id:int, new_val:String, id:int):
	
	match id:
		2:
			player_in_lobby[peer_id]["team"]=int(new_val)
			pass
		3:
			player_in_lobby[peer_id]["power"]=int(new_val)
			pass
		4:
			player_in_lobby[peer_id]["display_name"]=new_val
			MassUpdatePlayerList()
			pass
		5:
			player_in_lobby[peer_id]["ready"]=int(new_val)
			CheckReady()
			pass
	

func RemovePlayer(peer_id:int):
	player_in_lobby.erase(peer_id)
	CheckReady()
	MassUpdatePlayerList()

func DisplayReady():
	if(is_ready):
		ready_display.text="Ready!"
		ready_switch.text="Set to Not Ready."
	else:
		ready_display.text="Not Ready."
		ready_switch.text="Set to Ready!"

func OnLeaveDown():
	multiplayer.multiplayer_peer=null
	UImanager.SwitchUI("ConnectionGrid")
	pass # Replace with function body.


func Selector(items:Array, prev:int, id:int):
	
	change_id=id
	selection_list.clear()
	
	for i in items:
		selection_list.add_item(i)
	grid.visible=false
	sellector.visible=true
	selector_pick=prev
	
	

func OnBackDown():
	SetNewVal(selector_pick, change_id)
	grid.visible=true
	sellector.visible=false


func OnSelectDown():
	if(selection_list.get_selected_items().size()==0):
		return
	selector_pick=selection_list.get_selected_items()[0]
	SetNewVal(selector_pick, change_id)
	grid.visible=true
	sellector.visible=false

func SetNewVal( new_val:int, id:int):
	match id:
		0:
			gamemode_display.text=GameGlobalVar.gamemodes[new_val]
			lobby_params["GM"]=new_val
			
			pass
		1:
			map_display.text=GameGlobalVar.loaded_maps.keys()[new_val]
			lobby_params["Map"]=GameGlobalVar.loaded_maps.keys()[new_val]
			map_id=new_val
			pass
		2:
			team_display.text=GameGlobalVar.teams[new_val]
			player_in_lobby[net_id]["team"]=new_val
			Networking.LobbyDataSync(str(new_val), 2)
			pass
		3:
			ability_display.text=GameGlobalVar.powers[new_val]
			player_in_lobby[net_id]["power"]=new_val
			Networking.LobbyDataSync(str(new_val), 3)
			pass
	if(Networking.is_authority):
		Networking.LobbyUpdate(lobby_params)


func OnSwitchGamempde():
	Selector(GameGlobalVar.gamemodes, lobby_params["GM"], 0)


func OnSwitchMapDown():
	
	Selector(GameGlobalVar.loaded_maps.keys(), map_id, 1)


func OnSwitchTeamDown():
	Selector(GameGlobalVar.teams, player_in_lobby[net_id]["team"], 2)


func OnSwitchAbilityDown():
	Selector(GameGlobalVar.powers, player_in_lobby[net_id]["power"], 3)


func OnReadySwitchDown():
	
	
	is_ready=!is_ready
	player_in_lobby[net_id]["ready"]=is_ready
	DisplayReady()
	if(Networking.is_authority):
		CheckReady()
	else:
		if(is_ready):
			Networking.LobbyDataSync("1", 5)
		else:
			Networking.LobbyDataSync("0", 5)


func CheckReady():
	if(Networking.is_authority):
		var am:int=0
		var ready_am:int=0
		for i in player_in_lobby.values():
			am+=1;
			if(i["ready"]):
				ready_am+=1;
		
		ready_amount.text=str(ready_am)+"/"+str(am)
		lobby_params["Ready"]=str(ready_am)+"/"+str(am)
		Networking.LobbyUpdate(lobby_params)
		
		if(am==ready_am):
			Gameplay.StartGameServer(GameGlobalVar.loaded_maps[GameGlobalVar.loaded_maps.keys()[map_id]], player_in_lobby)

func OnSetNameDown():
	display_name=$Grid/SubGrid/Text_name.text
	player_in_lobby[net_id]["display_name"]=display_name
	if(Networking.is_authority):
		MassUpdatePlayerList()
	else:
		Networking.LobbyDataSync(display_name, 4)
