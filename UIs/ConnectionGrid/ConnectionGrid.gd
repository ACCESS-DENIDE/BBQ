extends Control

@onready var port_text = $Gid/SubGrid/Port_text
@onready var ip_text = $Gid/SubGrid/IP_text


func OnHostDown():
	Networking.Host(int(port_text.text))
	UImanager.SwitchUI("Lobby")


func OnConnectDown():
	Networking.ConnectTo(ip_text.text, int(port_text.text))
	


func OnBackDown():
	UImanager.SwitchUI("MainMenu")
