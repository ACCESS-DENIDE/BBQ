extends Resource

class_name Ability
@export var script_ref:Script

func Execute(executer:Node, executer_pos:Vector2):
	script_ref.Exec(executer, executer_pos)
	pass
