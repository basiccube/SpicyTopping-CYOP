// Initialize all CYOP variables
// Probably better if this was moved out of this event and into a script or something

global.cyop = true
global.cyopversion = 6

// Get CYOP settings
// There was going to be a settings menu at some point
// but that didn't happen
ini_open("modconfig.ini")
global.cyop_preload = ini_read_real("CYOP", "PreloadSprites", false)
global.cyop_afom = ini_read_real("CYOP", "AFOM", true)
ini_close()

global.cyop_tower = ""
global.cyop_level = ""
global.cyop_levelroom = ""
global.cyop_hublevel = ""
global.cyop_roomdata = -4
global.cyop_singlelevel = false
global.cyop_towerdir = cyop_set_directory()
global.cyop_secret = [-4, -4]
trace("CYOP directory: ", global.cyop_towerdir)

// Get CYOP object compatibility map
global.cyop_objectmap = -4
if (file_exists("spicytopping/cyopobjectids.json"))
	global.cyop_objectmap = json_parse(file_text_read_all("spicytopping/cyopobjectids.json"))
else
	show_message("CYOP object compatibility file not found! This will cause levels made using old versions of CYOP to not load correctly and will more than likely crash!")
	
// Get AFOM v2 object compatibility map
global.cyop_afomobjectmap = -4
if (file_exists("spicytopping/afomobjectids.json"))
	global.cyop_afomobjectmap = json_parse(file_text_read_all("spicytopping/afomobjectids.json"))
else
	show_message("AFOM object compatibility file not found! This will cause levels made using early versions of AFOM v2 to not load correctly and will more than likely crash!")
	
// Get CYOP tileset compatibility map
global.cyop_tilesetmap = -4
if (file_exists("spicytopping/cyoptilesets.json"))
	global.cyop_tilesetmap = json_parse(file_text_read_all("spicytopping/cyoptilesets.json"))
else
	show_message("CYOP tileset map file not found! Some tilesets will not work properly!")
	
// Get CYOP sprite compatibility map
global.cyop_spritemap = -4
if (file_exists("spicytopping/cyopsprites.json"))
	global.cyop_spritemap = json_parse(file_text_read_all("spicytopping/cyopsprites.json"))
else
	show_message("CYOP sprite map file not found! Some sprites won't appear properly!")
	
// Get CYOP music compatibility map
global.cyop_musicmap = -4
if (file_exists("spicytopping/cyopmusic.json"))
	global.cyop_musicmap = json_parse(file_text_read_all("spicytopping/cyopmusic.json"))
else
	show_message("CYOP music map file not found! Base game music in levels might not play!")
	
global.cyop_sprites = ds_map_create()
global.cyop_tilesets = ds_map_create()

// Get all towers and levels and get the tower info for the names and stuff
towerList = ds_list_create()
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

menu_x = 32
menu_y = 48
cursor_x = -64
cursor_y = menu_y
cursor_index = 0
fadeout = false
exitfadeout = false
directoryopen = false
fadealpha = 0
selection = 0
maxtowers = 13