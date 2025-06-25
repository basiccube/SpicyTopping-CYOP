// This uses functions from the official FMOD extension
// so it will not work with the one used by base PT!

if (!global.panic || (secret && global.cyop))
{
	if (global.cyop && room == rm_cyoplevel)
	{
		var _cyop_music = cyop_assets_get_music()
		
		if (cyop_assets_is_event(_cyop_music))
		{
			var mu = create_music_struct(_cyop_music)
			var prevmusic = music
		
			if (prevmusic == -4 || mu.event_name != prevmusic.event_name)
			{
				fmod_play_instance(mu.event)
				fmod_pause(mu.event, false)
			
				if (prevmusic != -4)
				{
					fmod_stop(prevmusic.event)
					if (prevmusic.secretevent != -4)
						fmod_stop(prevmusic.secretevent)
				}
				stop_cyop_music()
			
				music = mu
				savedmusicpos = 0
			}
		}
		else
		{
			if (cyop_musicname != _cyop_music && _cyop_music != "")
			{
				if (cyop_music != -4)
					fmod_sound_release(cyop_music)
				
				var musicFile = cyop_get_tower_dir() + "audio/" + _cyop_music + ".ogg"
				cyop_music = fmod_system_create_sound(global.cyop_towerdir == "towers" ? fmod_path_user(musicFile) : musicFile, FMOD_MODE.CREATESTREAM | FMOD_MODE.AS_2D | FMOD_MODE.LOOP_NORMAL)
				cyop_musicname = _cyop_music
				
				if (file_exists(cyop_get_tower_dir() + "audio/" + _cyop_music + ".ini"))
				{
					ini_open(cyop_get_tower_dir() + "audio/" + _cyop_music + ".ini")
				
					var _loopstart = ini_read_real("loopPoints", "start", 0)
					var _loopend = ini_read_real("loopPoints", "end", 0)
					var _length = fmod_sound_get_length(cyop_music, FMOD_TIMEUNIT.MS)
					
					// Convert to miliseconds
					_loopstart *= 1000
					_loopend *= 1000
					if (_loopend <= 0)
						_loopend = _length
				
					fmod_sound_set_loop_points(cyop_music, _loopstart, FMOD_TIMEUNIT.MS, _loopend, FMOD_TIMEUNIT.MS)
				
					ini_close()
				}
				
				var _music_bus = fmod_studio_system_get_bus("bus:/music")
				fmod_studio_bus_lock_channel_group(_music_bus)
				fmod_studio_system_flush_commands()
				var _music_channelgroup = fmod_studio_bus_get_channel_group(_music_bus)
				
				cyop_channel = fmod_system_play_sound(cyop_music, false, _music_channelgroup)
				if (secret)
					fmod_channel_set_position(cyop_channel, cyop_secretpos, FMOD_TIMEUNIT.MS)
				else if (secretend)
					fmod_channel_set_position(cyop_channel, savedmusicpos, FMOD_TIMEUNIT.MS)
				
				if (music != -4)
				{
					fmod_stop(music.event)
					if (music.secretevent != -4)
						fmod_stop(music.secretevent)
					music = -4
				}
			}
		}
	}
	else
	{
		var mu = ds_map_find_value(music_map, room)
		if (room == rm_utmtroom)
			mu = ds_map_find_value(music_map, asset_get_index(global.utmtRoomName))
		
		if !is_undefined(mu)
		{
			var prevmusic = music
			if (prevmusic == -4 || mu.event_name != prevmusic.event_name)
			{
				var bossroom = (room == boss_pepperman || room == boss_vigilante || room == boss_noise || room == boss_fakepep || room == boss_pizzaface)
				if (!bossroom)
				{
					fmod_play_instance(mu.event)
					fmod_pause(mu.event, false)
				}
			
				if (mu.continuous && prevmusic != -4)
				{
					var pos = fmod_get_timelinepos(prevmusic.event)
					pos = get_music_pos(pos, fmod_get_length(mu.event))
					fmod_set_timelinepos(mu.event, pos)
				}
			
				if (prevmusic != -4)
				{
					if (room == Mainmenu)
						fmod_stop(prevmusic.event, true)
					else
						fmod_stop(prevmusic.event)
				
					if (prevmusic.secretevent != -4)
						fmod_stop(prevmusic.secretevent)
				}
			
				music = mu
				savedmusicpos = 0
			
				if (room == war_1 || mu.event_name == "event:/music/extras/timetrial" || room == tower_finalhallway || room == Longintro)
					fmod_stop(music.event)
			}
		}
	}
	
	if instance_exists(obj_hungrypillar)
	{
		fmod_play_instance(pillarmusic)
		fmod_set_global("pillarfade", 0, true)
	}
	else
		fmod_stop(pillarmusic)
	
	var rm = room
	if (room == rm_utmtroom)
		rm = asset_get_index(global.utmtRoomName)
	if (music != -4 && music.roomstart != -4)
		music.roomstart(rm, music.event)
}

if (!instance_exists(obj_randomsecret))
{
	if (secret)
	{
		if (music != -4 && music.secretevent != -4)
		{
			fmod_play_instance(music.secretevent)
			fmod_pause(music.secretevent, false)
			
			pos = fmod_get_timelinepos(music.event)
			savedmusicpos = pos
			pos = get_music_pos(pos, fmod_get_length(music.secretevent))
			fmod_set_timelinepos(music.secretevent, pos)
			
			fmod_pause(music.event, true)
		}
		
		if (global.panic)
		{
			trace("Pausing panic music")
			savedpanicpos = fmod_get_timelinepos(panicmusic)
			fmod_pause(panicmusic, true)
		}
	}
	else if secretend
	{
		secretend = false
		if (music != -4)
		{
			fmod_stop(music.secretevent)
			fmod_pause(music.event, false)
			fmod_set_timelinepos(music.event, savedmusicpos)
		}
		
		if (global.panic)
		{
			if (global.cyop)
			{
				if (music != -4)
					fmod_stop(music.event)
			}
			
			stop_cyop_music()
			fmod_set_timelinepos(panicmusic, savedpanicpos)
			fmod_pause(panicmusic, false)
			trace("Resuming panic music")
		}
	}
}

if (room == rank_room || room == timesuproom)
{
	if (music != -4)
	{
		fmod_stop(music.event)
		fmod_stop(music.secretevent)
	}
}