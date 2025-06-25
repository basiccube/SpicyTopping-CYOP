var gate = id
with (obj_player1)
{
	if (place_meeting(x, y, other) && key_up && grounded && (state == states.normal || state == states.mach1 || state == states.mach2 || state == states.mach3) && !instance_exists(obj_fadeout) && state != states.victory && state != states.comingoutdoor)
	{
		if (other.levelName != -4 && global.cyop)
		{
			global.cyop_prevlevel = global.cyop_level
			global.cyop_prevroom = global.cyop_levelroom
			global.cyop_level = other.levelName
			global.leveltosave = other.levelName
		}
		
		with (obj_music)
			stop_music(true)
			
		if !global.cyop
		{
			global.leveltosave = other.level
			if (other.level == "escape")
				global.exitrank = true
		}
		global.leveltorestart = other.targetRoom
		
		backtohubstartx = x
		backtohubstarty = y
		backtohubroom = room
		
		mach2 = 0
		obj_camera.chargecamera = 0
		image_index = 0
		state = states.victory
		
		obj_player2.backtohubstartx = x
		obj_player2.backtohubstarty = y
		obj_player2.backtohubroom = room
		
		if global.coop
		{
			with (obj_player2)
			{
				x = obj_player1.x
				y = obj_player1.y
				mach2 = 0
				image_index = 0
				state = states.victory
			}
		}
		exit;
	}
}

if (floor(obj_player1.image_index) == obj_player1.image_number - 1 && obj_player1.state == states.victory)
{
	with (modifiertextID)
		fadeout = true
	instance_destroy(obj_modifiermenu)
	
	with (obj_player)
	{
		if (state == states.actor)
			state = states.victory
		
		targetDoor = "A"
		targetRoom = other.targetRoom
		
		if !instance_exists(obj_fadeout)
		{
			with (instance_create(x, y, obj_fadeout))
			{
				group_arr = gate.group_arr
				restarttimer = true
			}
			scr_resetmemory()
		}
	}
}
