// This is included because some functions here
// are used by the CYOP code that's in obj_music.
// All of this uses the official GameMaker FMOD extension
// and not the one that's used by base PT!

function add_music(_room_name, _event_name, _secretevent_name, _continuous, _roomstart_func = -4)
{
	var music_struct = 
	{
		event_name : _event_name,
		event : -4,
		secretevent_name : _secretevent_name,
		secretevent : -4,
		continuous : _continuous,
		roomstart : -4,
	}
	
	with (music_struct)
	{
		if (_roomstart_func != -4)
			roomstart = method(self, _roomstart_func)
		if (_event_name != -4)
		{
			event_name = _event_name
			event = fmod_create(_event_name)
		}
		if (_secretevent_name != -4)
		{
			secretevent_name = _secretevent_name
			secretevent = fmod_create(_secretevent_name)
		}
	}
	
	ds_map_set(music_map, _room_name, music_struct)
	return music_struct;
}

function create_music_struct(_event_name)
{
	var music_struct = 
	{
		event_name : _event_name,
		event : -4,
		secretevent_name : "",
		secretevent : -4,
		continuous : false,
		roomstart : -4,
	}
	
	with (music_struct)
	{
		if (_event_name != -4)
		{
			event_name = _event_name
			event = fmod_create(_event_name)
		}
	}
	
	return music_struct;
}

function stop_cyop_music()
{
	if (cyop_channel != -4)
	{
		fmod_sound_release(cyop_music)
		cyop_channel = -4
		cyop_music = -4
		cyop_musicname = ""
	}
}

function stop_music(fadeout = false, forcestop = false)
{
	if (music != -4)
	{
		if ((obj_pause.pause || fadeout) && !forcestop)
		{
			fmod_stop(music.event)
			fmod_stop(music.secretevent)
			music = -4
		}
		else
		{
			fmod_stop(music.event, true)
			fmod_stop(music.secretevent, true)
			music = -4
		}
	}
	
	fmod_stop(pillarmusic)
	fmod_stop(panicmusic)
	
	stop_cyop_music()
}

function get_music_pos(pos, length)
{
	while (pos > length)
		pos -= length
	if (pos < 1)
		pos = 1
	
	return pos;
}

function hub_state(_room, _event)
{
	var s = 0
	switch _room
	{
		case tower_entrance:
		case tower_flooraentrance:
		case tower_sidearea:
			s = 0
			break
		case tower_1:
		case tower_cheftask1:
		case tower_entrancehall:
		case tower_mainentrance:
		case tower_johngutter:
			s = 1
			break
		case tower_2:
		case tower_cheftask2:
			s = 2
			break
		case tower_3:
		case tower_cheftask3:
			s = 3
			break
		case tower_4:
		case tower_cheftask4:
			s = 4
			break
		case tower_5:
		case tower_cheftask5:
			s = 5
			break
	}
	
	fmod_set_value(_event, "state", s, true)
}