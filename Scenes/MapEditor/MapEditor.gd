extends TileMap

var cam_ref:Camera2D
var cam_speed=50

var edited_map:TileMap

var block_type=[Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(4,0), Vector2i(5,0), Vector2i(5,1), Vector2i(5,2), Vector2i(15,3), Vector2i(2,0), Vector2i(1,0)]
var layer=0
var selected_block=0

var is_disabled:bool=false

var is_erase:bool=false

var is_loaded:bool=true

var base_map_cou=0

var mode:int=1

var spawner_mode:int=0
var spawner_prc:int=50

var spawner_info={}

var start_point_global:Vector2i=Vector2i(0,0)
var end_point_global:Vector2i=Vector2i(0,0)

func SetSpawnerMode(mode:int):
	spawner_mode=mode

func SetSpawnerData(perc:float):
	spawner_prc=perc

func SetDrawMode(new_mode:int):
	mode=new_mode

func SetPaintBlock(new_block_id:int):
	selected_block=new_block_id
	
	if(new_block_id<5):
		layer=0
	elif(new_block_id<9):
		layer=1
	else:
		layer=2
	

func Disable():
	is_disabled=true

func Enable():
	is_disabled=false

func _ready():
	cam_ref=$Camera2D
	edited_map=$"."
	cam_ref.make_current()

var begin_pos_curs:Vector2i
var end_pos_curs:Vector2i

var begin_pos_mem:Vector2i
var end_pos_mem:Vector2i

var is_inprogress=false

func _process(delta):
	if(is_disabled || is_loaded):
		if(Input.is_action_just_released("Primary")):
			is_loaded=false
		edited_map.clear_layer(3)
		return
	var direction:Vector2=Vector2(0,0)
	
	
	if(Input.is_action_just_pressed("ZoomIn")):
		if(cam_ref.zoom.x<4):
			cam_ref.zoom+=Vector2(0.5, 0.5)
		else:
			cam_ref.zoom=Vector2(4, 4)
		
	
	if(Input.is_action_just_pressed("ZooomOut")):
		if(cam_ref.zoom.x>0.5):
			cam_ref.zoom-=Vector2(0.5, 0.5)
		else:
			cam_ref.zoom=Vector2(0.5, 0.5)
	
	direction.x = Input.get_axis("MoveLeft", "MoveRight")
	direction.y = Input.get_axis("MoveUp", "MoveDown")
	
	cam_ref.position=cam_ref.position+Vector2(direction.x*(cam_speed/cam_ref.zoom.x), direction.y*(cam_speed/cam_ref.zoom.x))
	var mouse_pos=get_global_mouse_position()
	if(Input.is_action_just_pressed("Primary") && (!is_erase)):
		begin_pos_mem=Vector2(floor(mouse_pos.x/32), floor(mouse_pos.y/32))
	
	
	var set_pos:Vector2i=Vector2i(0,0)
	
	#if(selected_block>4 && selected_block<10):
		#mouse_pos=mouse_pos+Vector2(16,16)
	set_pos=Vector2(floor(mouse_pos.x/32), floor(mouse_pos.y/32))
	
	
	
	
	if(Input.is_action_pressed("Primary") && (!is_erase)):
		
		
		is_inprogress=true
		
		
		end_pos_mem=set_pos
		var begin_pos:Vector2i=begin_pos_mem
		var end_pos:Vector2i=end_pos_mem
		
		
		
		
		if(set_pos.x<begin_pos_curs.x):
			begin_pos_curs.x=set_pos.x
		if(set_pos.y<begin_pos_curs.y):
			begin_pos_curs.y=set_pos.y
		
		if(set_pos.x>end_pos_curs.x):
			end_pos_curs.x=set_pos.x
		if(set_pos.y>end_pos_curs.y):
			end_pos_curs.y=set_pos.y
		
		var pop=0
		
		
		
		match mode:
			0:
				edited_map.set_cell(3, set_pos, layer, block_type[selected_block])
				pass
			1:
				
				if((begin_pos.x>end_pos.x)  || (begin_pos.y>end_pos.y)):
					pop=end_pos.x
					end_pos.x=begin_pos.x
					begin_pos.x=pop
					pop=end_pos.y
					end_pos.y=begin_pos.y
					begin_pos.y=pop
				
				
				if(begin_pos.x>end_pos.x):
					pop=end_pos.x
					end_pos.x=begin_pos.x
					begin_pos.x=pop
					pop=end_pos.y
					end_pos.y=begin_pos.y
					begin_pos.y=pop
				
				edited_map.clear_layer(3)
				if(begin_pos.x==end_pos.x):
					for i in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(3, Vector2i(begin_pos.x, i) , layer, block_type[selected_block])
				elif(begin_pos.y==end_pos.y):
					for i in range(begin_pos.x, end_pos.x+1):
						edited_map.set_cell(3, Vector2i(i, begin_pos.y) , layer, block_type[selected_block])
				else:
					var delta_dist:Vector2i=Vector2i(end_pos_mem.x-begin_pos_mem.x, end_pos_mem.y-begin_pos_mem.y)
					var last_mod:int=begin_pos.y
					for i in range (begin_pos.x, end_pos.x+1):
						var x:int=i
						var y:int
						var x1:int=begin_pos.x
						var y1:int=begin_pos.y
						var x2:int=end_pos.x
						var y2:int=end_pos.y
						var mem_y:int
						
						
						y=ceili((((x-x1)*(y2-y1))/(x2-x1))+y1)
						mem_y=y
						if(abs(y-last_mod)>1):
							if(y<last_mod):
								pop=y
								y=last_mod
								last_mod=pop
								
							
							var shifter=delta_dist.x*delta_dist.y
							
							if(shifter<0):
								for g in range(last_mod, y):
									edited_map.set_cell(3, Vector2i(x, g) , layer,block_type[selected_block])
							else:
								for g in range(last_mod, y):
									edited_map.set_cell(3, Vector2i(x, g+1) , layer,block_type[selected_block])
							
						else:
							edited_map.set_cell(3, Vector2i(x, y) , layer, block_type[selected_block])
						last_mod=mem_y
				pass
			2:
				edited_map.clear_layer(3)
				
				if(begin_pos_mem.x>end_pos_mem.x):
					
					end_pos.x=begin_pos_mem.x
					begin_pos.x=end_pos_mem.x
				
				
				
				if(begin_pos_mem.y>end_pos_mem.y):
					
					end_pos.y=begin_pos_mem.y
					begin_pos.y=end_pos_mem.y
				
				
				
				for i in range(begin_pos.x, end_pos.x+1):
					for g in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(3, Vector2i(i, g) , layer, block_type[selected_block])
				pass
			3:
				edited_map.clear_layer(3)
				
				if(begin_pos_mem.x>end_pos_mem.x):
					
					end_pos.x=begin_pos_mem.x
					begin_pos.x=end_pos_mem.x
				
				
				
				if(begin_pos_mem.y>end_pos_mem.y):
					
					end_pos.y=begin_pos_mem.y
					begin_pos.y=end_pos_mem.y
				
				
				
				for i in range(begin_pos.x, end_pos.x+1):
					for g in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(3, Vector2i(i, g) , layer, block_type[selected_block])

				
				for i in range(begin_pos.x+1, end_pos.x):
					for g in range(begin_pos.y+1, end_pos.y):
						edited_map.erase_cell(3, Vector2i(i, g))

				
				pass
	else:
		if(!(is_inprogress||is_erase)):
			
			edited_map.clear_layer(3)
			edited_map.set_cell(3, set_pos, layer, block_type[selected_block])
	
	
	
	
	if(Input.is_action_just_released("Primary") && (!is_erase)):
		is_inprogress=false
		var base_cou=base_map_cou
		for i in range(begin_pos_curs.x-1, end_pos_curs.x+1):
			for g in range(begin_pos_curs.y-1, end_pos_curs.y+1):
				if(edited_map.get_cell_atlas_coords(3, Vector2i(i, g))!=Vector2i(-1, -1)):
					if(selected_block>8):
						if(selected_block==9):
							base_cou+=1
							if(base_cou<3):
								edited_map.set_cell(4, Vector2i(i, g), layer , edited_map.get_cell_atlas_coords(3, Vector2i(i, g)))
						else:
							edited_map.set_cell(4, Vector2i(i, g), layer , edited_map.get_cell_atlas_coords(3, Vector2i(i, g)))
							spawner_info[str(i)+":"+str(g)]={}
							spawner_info[str(i)+":"+str(g)]["Mode"]=spawner_mode
							spawner_info[str(i)+":"+str(g)]["Percent"]=spawner_prc
					else:
						edited_map.set_cell(layer, Vector2i(i, g), layer , edited_map.get_cell_atlas_coords(3, Vector2i(i, g)))
						
					if(selected_block>4):
						edited_map.set_cells_terrain_connect(layer,[Vector2i(i, g)], 0, selected_block-5)
					edited_map.erase_cell(3, Vector2i(i, g))
		if(start_point_global.x>begin_pos_curs.x):
			start_point_global.x=begin_pos_curs.x
		if(start_point_global.y>begin_pos_curs.y):
			start_point_global.y=begin_pos_curs.y
		if(end_point_global.x<end_pos_curs.x):
			end_point_global.x=end_pos_curs.x
		if(end_point_global.y<end_pos_curs.y):
			end_point_global.y=end_pos_curs.y
		begin_pos_curs=Vector2i(0,0)
		end_pos_curs=Vector2i(0,0)
		
		if(base_cou>2):
			OS.alert("Can't be more than two bases.")
			base_map_cou=2
		else:
			base_map_cou=base_cou
	
	
	
	
	
	if(Input.is_action_just_pressed("Secondary") && (!is_inprogress)):
		is_erase=true
		begin_pos_mem=Vector2(floor(mouse_pos.x/32), floor(mouse_pos.y/32))
	
	
	if(Input.is_action_pressed("Secondary") && (!is_inprogress)):
		
		
		end_pos_mem=set_pos
		var begin_pos:Vector2i=begin_pos_mem
		var end_pos:Vector2i=end_pos_mem
		
		
		
		
		if(set_pos.x<begin_pos_curs.x):
			begin_pos_curs.x=set_pos.x
		if(set_pos.y<begin_pos_curs.y):
			begin_pos_curs.y=set_pos.y
		
		if(set_pos.x>end_pos_curs.x):
			end_pos_curs.x=set_pos.x
		if(set_pos.y>end_pos_curs.y):
			end_pos_curs.y=set_pos.y
		
		var pop=0
		
		
		
		match mode:
			0:
				edited_map.set_cell(3, set_pos, 2, Vector2i(0,0))
				pass
			1:
				
				if((begin_pos.x>end_pos.x)  || (begin_pos.y>end_pos.y)):
					pop=end_pos.x
					end_pos.x=begin_pos.x
					begin_pos.x=pop
					pop=end_pos.y
					end_pos.y=begin_pos.y
					begin_pos.y=pop
				
				
				if(begin_pos.x>end_pos.x):
					pop=end_pos.x
					end_pos.x=begin_pos.x
					begin_pos.x=pop
					pop=end_pos.y
					end_pos.y=begin_pos.y
					begin_pos.y=pop
				
				edited_map.clear_layer(3)
				if(begin_pos.x==end_pos.x):
					for i in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(3, Vector2i(begin_pos.x, i) ,  2, Vector2i(0,0))
				elif(begin_pos.y==end_pos.y):
					for i in range(begin_pos.x, end_pos.x+1):
						edited_map.set_cell(3, Vector2i(i, begin_pos.y) , 2, Vector2i(0,0))
				else:
					var delta_dist:Vector2i=Vector2i(end_pos_mem.x-begin_pos_mem.x, end_pos_mem.y-begin_pos_mem.y)
					var last_mod:int=begin_pos.y
					for i in range (begin_pos.x, end_pos.x+1):
						var x:int=i
						var y:int
						var x1:int=begin_pos.x
						var y1:int=begin_pos.y
						var x2:int=end_pos.x
						var y2:int=end_pos.y
						var mem_y:int
						
						
						y=ceili((((x-x1)*(y2-y1))/(x2-x1))+y1)
						mem_y=y
						if(abs(y-last_mod)>1):
							if(y<last_mod):
								pop=y
								y=last_mod
								last_mod=pop
								
							
							var shifter=delta_dist.x*delta_dist.y
							
							if(shifter<0):
								for g in range(last_mod, y):
									edited_map.set_cell(3, Vector2i(x, g) ,  2, Vector2i(0,0))
							else:
								for g in range(last_mod, y):
									edited_map.set_cell(3, Vector2i(x, g+1) ,  2, Vector2i(0,0))
							
						else:
							edited_map.set_cell(3, Vector2i(x, y) ,  2, Vector2i(0,0))
						last_mod=mem_y
				pass
			2:
				edited_map.clear_layer(3)
				
				if(begin_pos_mem.x>end_pos_mem.x):
					
					end_pos.x=begin_pos_mem.x
					begin_pos.x=end_pos_mem.x
				
				
				
				if(begin_pos_mem.y>end_pos_mem.y):
					
					end_pos.y=begin_pos_mem.y
					begin_pos.y=end_pos_mem.y
				
				
				
				for i in range(begin_pos.x, end_pos.x+1):
					for g in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(3, Vector2i(i, g) , 2, Vector2i(0,0))
				pass
			3:
				edited_map.clear_layer(3)
				
				if(begin_pos_mem.x>end_pos_mem.x):
					
					end_pos.x=begin_pos_mem.x
					begin_pos.x=end_pos_mem.x
				
				
				
				if(begin_pos_mem.y>end_pos_mem.y):
					
					end_pos.y=begin_pos_mem.y
					begin_pos.y=end_pos_mem.y
				
				
				
				for i in range(begin_pos.x, end_pos.x+1):
					for g in range(begin_pos.y, end_pos.y+1):
						edited_map.set_cell(3, Vector2i(i, g) , 2, Vector2i(0,0))

				
				for i in range(begin_pos.x+1, end_pos.x):
					for g in range(begin_pos.y+1, end_pos.y):
						edited_map.erase_cell(3, Vector2i(i, g))
	
	
	
	
	if(Input.is_action_just_released("Secondary") && (!is_inprogress)):
		is_erase=false
		for i in range(begin_pos_curs.x-1, end_pos_curs.x+1):
			for g in range(begin_pos_curs.y-1, end_pos_curs.y+1):
				if(edited_map.get_cell_atlas_coords(3, Vector2i(i, g))==Vector2i(0, 0)):
					if(edited_map.get_cell_atlas_coords(1, Vector2i(i, g))==Vector2i(2, 0) && edited_map.get_cell_source_id(1, Vector2i(i, g))==2):
						base_map_cou-=1
					edited_map.erase_cell(0, Vector2i(i, g))
					edited_map.erase_cell(1, Vector2i(i, g))
					edited_map.erase_cell(4, Vector2i(i, g))
					edited_map.erase_cell(3, Vector2i(i, g))
					spawner_info.erase(str(i)+":"+str(g))
		begin_pos_curs=Vector2i(0,0)
		end_pos_curs=Vector2i(0,0)
	pass


func StringifyMap()->Dictionary:
	var x:int=0
	var y:int=0
	var outp={}
	var tile:Vector3i
	
	for i in range(start_point_global.x-1, end_point_global.x+1):
		for g in range(start_point_global.y-1, end_point_global.y+1):
			if(edited_map.get_cell_atlas_coords(0, Vector2i(i, g))!=Vector2i(-1, -1)):
				tile=Vector3i(edited_map.get_cell_atlas_coords(0, Vector2i(i, g)).x, edited_map.get_cell_atlas_coords(0, Vector2i(i, g)).y, edited_map.get_cell_alternative_tile(0, Vector2i(i, g)))
				outp[str(x)+":"+str(y)+":0"]=tile
			if(edited_map.get_cell_atlas_coords(1, Vector2i(i, g))!=Vector2i(-1, -1)):
				tile=Vector3i(edited_map.get_cell_atlas_coords(1, Vector2i(i, g)).x, edited_map.get_cell_atlas_coords(1, Vector2i(i, g)).y, edited_map.get_cell_alternative_tile(1, Vector2i(i, g)))
				outp[str(x)+":"+str(y)+":1"]=tile
			if(edited_map.get_cell_atlas_coords(4, Vector2i(i, g))!=Vector2i(-1, -1)):
				tile=Vector3i(edited_map.get_cell_atlas_coords(4, Vector2i(i, g)).x, edited_map.get_cell_atlas_coords(4, Vector2i(i, g)).y, edited_map.get_cell_alternative_tile(4, Vector2i(i, g)))
				outp[str(x)+":"+str(y)+":2"]=tile
			y+=1
		x+=1
		y=0
	
	return outp
