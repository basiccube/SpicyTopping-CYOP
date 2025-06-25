with (obj_player1)
	state = states.titlescreen
scr_getinput()

if (fadeout)
{
	if (fadealpha < 1)
		fadealpha += 0.1
	else
	{
		if (exitfadeout)
		{
			room_goto(rm_menuinit)
			with (obj_player1)
			{
				character = "P"
				modcharacter = -4
				scr_characterspr()
			}
			scr_playerreset()
		}
		else
		{
			with (obj_player)
			{
				targetDoor = "A"
				if instance_exists(obj_exitgate)
					state = states.comingoutdoor
				else
					state = states.normal
			}
			
			with (obj_music)
				stop_music()
			
			cyop_goto_level()
		}
	}
}

cursor_index += 0.35
cursor_x = lerp(cursor_x, menu_x, 0.25)
cursor_y = lerp(cursor_y, menu_y + (36 * (selection - (maxtowers * (selection div maxtowers)))), 0.375)

if (directoryopen)
{
	if (keyboard_check_pressed(vk_anykey) || scr_checkanygamepad(obj_inputAssigner.player_input_device[0]) != -4)
	{
		cyop_get_towers()
		for (var i = 0; i < ds_list_size(towerList); i++)
		{
			var listStruct = ds_list_find_value(towerList, i)
			var infoResult = cyop_get_tower_info(listStruct.towerName)
	
			if (infoResult != -4)
			{
				variable_struct_set(listStruct, "towerInfo", infoResult)
				ds_list_set(towerList, i, listStruct)
			}
			else
			{
				ds_list_delete(towerList, i)
				i--
			}
		}
		
		directoryopen = false
		selection = 0
		key_jump = false
		key_slap2 = false
		key_taunt2 = false
	}
	exit;
}

if instance_exists(obj_modifiermenu)
	exit;

var prevselection = selection
moveselect = (-key_up2 + key_down2)
selection += moveselect

if (selection >= ds_list_size(towerList))
	selection = 0
else if (selection < 0)
	selection = ds_list_size(towerList) - 1

if (prevselection != selection)
	fmod_play("event:/sfx/menu/menustep")

// Load selected level/tower
if (key_jump && !fadeout && ds_list_size(towerList) > 0)
{
	var selectedTower = ds_list_find_value(towerList, selection)
	if (selectedTower.towerInfo.mainlevel == "")
	{
		show_message("This tower does not have a main level selected.")
		exit;
	}
	
	with (obj_savesystem)
	{
		showicon = 1
		icon_alpha = 3
	}
	
	global.cyop_tower = selectedTower.towerName
	global.cyop_level = selectedTower.towerInfo.mainlevel
	global.cyop_levelroom = "main"
	global.cyop_roomdata = cyop_get_level_roomdata()
	
	level_info = cyop_get_level_info()
	if (selectedTower.towerInfo.type == 0)
	{
		global.cyop_hublevel = global.cyop_level
		global.cyop_singlelevel = false
		level_info.hubworld = true
	}
	else
	{
		global.leveltorestart = global.cyop_levelroom
		global.cyop_singlelevel = true
	}
	
	global.srank = floor(level_info.pscore)
	global.minutes = floor(level_info.escapetime / 60)
	global.seconds = floor(level_info.escapetime % 60)
	
	cyop_assets_reset()
	cyop_assets_load()
	cyop_instancemanager_reset()
	
	fadeout = true
}

// Exit and fade out to main menu
if (key_slap2 && !fadeout)
{
	cyop_assets_reset()
	ds_map_destroy(global.cyop_sprites)
	ds_map_destroy(global.cyop_tilesets)
	global.cyop_roomdata = -4
	global.cyop = false
	fadeout = true
	exitfadeout = true
}

// Open modifier menu if single level
if (key_taunt2 && !fadeout && ds_list_size(towerList) > 0)
{
	var selectedTower = ds_list_find_value(towerList, selection)
	if (selectedTower.towerInfo.type == 1)
		instance_create(x, y, obj_modifiermenu)
}

// Open tower folder
// Uses libxprocess for doing this
if (key_attack2 && !fadeout)
{
	if (global.cyop_towerdir == "towers")
	{
		if !directory_exists("towers")
			directory_create("towers")
		open_directory(game_save_id + "towers")
	}
	else
		open_directory(global.cyop_towerdir)
	directoryopen = true
}