extends Node

var pings={}

var player_timestamps={}

func GetPlayerDeltatime(id:int)->float:
	var ret:float
	var new_stamp:int=Time.get_ticks_msec()
	ret=new_stamp-player_timestamps[id]
	player_timestamps[id]=new_stamp
	return ret

func RegisterStamp(id:int):
	player_timestamps[id]=Time.get_ticks_msec()

func RemoveStampData(id:int):
	player_timestamps.erase(id)

