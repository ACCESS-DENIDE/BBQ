extends TileMap

var cam_ref:Camera2D
var cam_speed=50

var edited_map:TileMap


func _ready():
	UImanager.SwitchUI("MapEditor")
	cam_ref=$Camera2D
	edited_map=$"."

var begin_pos_curs:Vector2i
var end_pos_curs:Vector2i

var begin_pos:Vector2i
var end_pos:Vector2i

var mode:int=1

func _process(delta):
	var direction:Vector2=Vector2(0,0)
	
	
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	cam_ref.position=cam_ref.position+Vector2(direction.x*(cam_speed/cam_ref.zoom.x), direction.y*(cam_speed/cam_ref.zoom.x))
	
	if(Input.is_action_just_pressed("Primary")):
		var mouse_pos=get_global_mouse_position()
		begin_pos=Vector2(floor(mouse_pos.x/32), floor(mouse_pos.y/32))
	
	if(Input.is_action_pressed("Primary")):
		var set_pos:Vector2i=Vector2i(0,0)
		var mouse_pos=get_global_mouse_position()
		set_pos=Vector2(floor(mouse_pos.x/32), floor(mouse_pos.y/32))
		
		end_pos=set_pos
		
		if(set_pos.x<begin_pos_curs.x):
			begin_pos_curs.x=set_pos.x
		if(set_pos.y<begin_pos_curs.y):
			begin_pos_curs.y=set_pos.y
		
		if(set_pos.x>end_pos_curs.x):
			end_pos_curs.x=set_pos.x
		if(set_pos.y>end_pos_curs.y):
			end_pos_curs.y=set_pos.y
		
		
		match mode:
			0:
				edited_map.set_cell(2, set_pos, 0, Vector2i(0,0))
				pass
			1:
				edited_map.clear_layer(2)
				if(begin_pos.x==end_pos.x):
					for i in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(2, Vector2i(begin_pos.x, i) , 0, Vector2i(0,0))
				elif(begin_pos.y==end_pos.y):
					for i in range(begin_pos.x, end_pos.x+1):
						edited_map.set_cell(2, Vector2i(i, begin_pos.y) , 0, Vector2i(0,0))
				else:
					var delta_dist:Vector2i=Vector2i(end_pos.x-begin_pos.x, end_pos.y-begin_pos.y)
					
					for i in range (begin_pos.x, end_pos.x+1):
						var x:int
						var y:int
						var x1:int
						var y1:int
						var x2:int
						var y2:int
						
						var draw_y=(((begin_pos.x+i)-begin_pos.x)*(end_pos.y-begin_pos.y))/(end_pos.x-begin_pos.x)+begin_pos.y
						edited_map.set_cell(2, Vector2i(begin_pos.x+i, draw_y) , 0, Vector2i(0,0))
				pass
			2:
				pass
			3:
				pass
	
	if(Input.is_action_just_released("Primary")):
		for i in range(begin_pos_curs.x, end_pos_curs.x+1):
			for g in range(begin_pos_curs.y, end_pos_curs.y+1):
				if(edited_map.get_cell_atlas_coords(2, Vector2i(i, g))!=Vector2i(-1, -1)):
					edited_map.set_pattern(0, Vector2i(i, g), edited_map.get_pattern(2, [Vector2i(i,g)]))
					edited_map.erase_cell(2, Vector2i(i, g))
		begin_pos_curs=Vector2i(0,0)
		end_pos_curs=Vector2i(0,0)
	
	pass
