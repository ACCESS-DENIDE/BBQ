extends Node

var b_team=[]
var r_team=[]

var red:int=0
var blue:int=0

var no_team=[]

var death:Callable
var respawnloc:Callable
var ags:Callable
var remove:Callable
var addplayer:Callable
var getally:Callable
var teamdistrib:Callable
var startgm:Callable


func PlayerDeath(ref:Node):
	death.call(ref)

func AditionalGemplaySignal(data:String):
	ags.call(data)

func GetRespawnLock(ref:Node)->Vector2:
	return respawnloc.call(ref)

func GetAlly(ref:Node)->Array:
	return getally.call(ref)

func RemovePlayer(id:String):
	remove.call(id)

func AddPlayer(id:int, id_abil:int):
	addplayer.call(id, id_abil)

func AssignTeams(inp:Dictionary):
	teamdistrib.call(inp)	

func StartGame():
	startgm.call()

func AsignGamemode(id:int):
	match id:
		0:
			death=Callable(self, "Nothing")
			respawnloc=Callable(self, "GetRandomSpawn")
			ags=Callable(self, "Nothing")
			remove=Callable(self, "RoundTeamRemove")
			addplayer=Callable(self, "RoundTeamAdd")
			getally=Callable(self, "GetTeamAlly")
			teamdistrib=Callable(self, "EvenDistribAdd")
			startgm=Callable(self, "Nothing")
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

func Nothing(a=null, b=null):
	pass

func EvenDistribAdd(inp:Dictionary):
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

func RoundTeamAdd(id:int, id_abil:int):
	if(blue>red):
		Gameplay.player_inf[id]["team"]=2
		Gameplay.AddPuppet(id, id_abil, 2)
		red+=1
	else:
		Gameplay.player_inf[id]["team"]=1
		Gameplay.AddPuppet(id, id_abil, 1)
		blue+=1

func RoundTeamRemove(id:String):
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

func GetTeamAlly(ref:Node):
	var ret=[]
	match ref.my_team:
		1:
			ret=b_team
			pass
		2:
			ret=r_team
			pass
	
	return ret

func RoundRobinArray(inp:Array)->Array:
	inp.shuffle()
	return inp


var rr_list:Array
func GetRandomSpawn(ref:Node)->Vector2:
	if(rr_list.size()==0):
		for i in Gameplay.player_spawners:
			rr_list.push_back(i)
		randomize()
		rr_list.shuffle()
	
	return rr_list.pop_front()
