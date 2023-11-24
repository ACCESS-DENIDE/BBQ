extends Node

var pings={}

var player_timestamps={}

func GetPlayerDeltatime(id:int, new_stamp:float)->float:
	var ret:float
	ret=new_stamp-player_timestamps[id]
	player_timestamps[id]=new_stamp
	return ret

func RegisterStamp(id:int, new_stamp:float):
	player_timestamps[id]=new_stamp

func RemoveStampData(id:int):
	player_timestamps.erase(id)

