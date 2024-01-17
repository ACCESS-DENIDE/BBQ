extends Node

var b_team=[]
var r_team=[]

var red:int=0
var blue:int=0

var no_team=[]

var death:Callable
var respawn:Callable
var ags:Callable
var remove:Callable
var addplayer:Callable
var getally:Callable


func PlayerDeath(id:String):
	pass

func AditionalGemplaySignal(data:String):
	pass

func PlayerRespawn(id:String):
	pass

func GetAlly(ref:Node)->Array:
	var ret=[]
	match ref.my_team:
		1:
			ret=b_team
			pass
		2:
			ret=r_team
			pass
	
	return ret
	pass

func RemovePlayer(id:String):
	match (Gameplay.player_ref[id].my_team):
		0:
			pass
		1:
			blue-=1
			pass
		2:
			red-=1
			pass
		3:
			pass
	pass

func AddPlayer(id:int, id_abil:int):
	if(blue>red):
		Gameplay.player_inf[id]["team"]=2
		Gameplay.AddPuppet(id, id_abil, 2)
		red+=1
	else:
		Gameplay.player_inf[id]["team"]=1
		Gameplay.AddPuppet(id, id_abil, 1)
		blue+=1

func AssignTeams(inp:Dictionary):
	for i in inp.values():
		if(i["team"]==1):
			blue+=1
		elif (i["team"]==2):
			red+=1
	
	for i in inp.values():
		if(i["team"]==0):
			if(blue>red):
				i["team"]=2
				red+=1
			else:
				i["team"]=1
				blue+=1
	

func AsignGamemode(id:int):
	match id:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass
		5:
			pass
		6:
			pass
		7:
			pass
		8:
			pass
		9:
			pass
	pass


