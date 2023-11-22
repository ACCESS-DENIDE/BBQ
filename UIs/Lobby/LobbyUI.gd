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

var display_name:String

var is_ready=false

var selector_pick:int=-1
var change_id:int=-1

var selected_gamemode:int=0
var selected_map:int=0
var selected_team:int=0
var selected_power:int=0

func _ready():
	if(Networking.is_authority):
		open_switch_gamemode.disabled=false
		open_switch_map.disabled=false
	else:
		open_switch_gamemode.disabled=true
		open_switch_map.disabled=true
		
	gamemode_display.text=GameConstants.gamemodes[selected_gamemode]
	map_display.text=GameConstants.loaded_maps.keys()[selected_map]
	team_display.text=GameConstants.teams[selected_team]
	ability_display.text=GameConstants.powers[selected_power]
	display_name="GIGA NIGGA"
	DisplayReady()
	Networking.lobby_ui_ref=self
	AddPlayer(1)

func AddPlayer(peer_id:int):
	player_in_lobby[peer_id]={}
	player_in_lobby[peer_id]["display_name"]="GIGGA NIGGA"
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
	

func DisplayReady():
	if(is_ready):
		ready_display.text="Ready!"
		ready_switch.text="Set to Not Ready."
	else:
		ready_display.text="Not Ready."
		ready_switch.text="Set to Ready!"

func OnLeaveDown():
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
			gamemode_display.text=GameConstants.gamemodes[new_val]
			selected_gamemode=new_val
			
			pass
		1:
			map_display.text=GameConstants.loaded_maps.keys()[new_val]
			selected_map=new_val
			
			pass
		2:
			team_display.text=GameConstants.teams[new_val]
			selected_team=new_val
			player_in_lobby[1]["team"]=new_val
			pass
		3:
			ability_display.text=GameConstants.powers[new_val]
			selected_power=new_val
			player_in_lobby[1]["team"]=new_val
			pass

func OnSwitchGamempde():
	Selector(GameConstants.gamemodes, selected_gamemode, 0)


func OnSwitchMapDown():
	Selector(GameConstants.loaded_maps.keys(), selected_gamemode, 1)


func OnSwitchTeamDown():
	Selector(GameConstants.teams, selected_gamemode, 2)


func OnSwitchAbilityDown():
	Selector(GameConstants.powers, selected_gamemode, 3)


func OnReadySwitchDown():
	is_ready=!is_ready
	DisplayReady()
	CheckReady()


func CheckReady():
	var am:int=0
	var ready_am:int=0
	for i in player_in_lobby.values():
		am+=1;
		if(i["ready"]==1):
			ready_am+=1;
	
	ready_amount.text=str(ready_am)+"/"+str(am)
	

func OnSetNameDown():
	display_name=$Grid/SubGrid/Text_name.text
	player_in_lobby[1]["display_name"]=display_name
