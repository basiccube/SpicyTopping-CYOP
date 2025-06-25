global.leveltorestart = -4
global.leveltosave = -4
global.level_minutes = 0
global.level_seconds = 0
fmod_release(resultsmusic)
fmod_stop(resultsmusic)
scr_playerreset()
scr_resetmemory()

with (obj_player)
{
	targetDoor = "BACKTOHUB"
	if (global.cyop)
	{
		if (global.cyop_singlelevel)
		{
			obj_player1.targetRoom = rm_cyopmenu
			obj_player1.targetDoor = "A"
			room_goto(rm_cyopmenu)
		}
		else
		{
			global.cyop_level = global.cyop_prevlevel
			scr_room_goto(global.cyop_prevroom)
		}
	}
	else
	{
		targetRoom = obj_player1.backtohubroom
		room = obj_player1.backtohubroom
	}
	
	x = obj_player1.backtohubstartx
	y = obj_player1.backtohubstarty
	image_blend = c_white
}
