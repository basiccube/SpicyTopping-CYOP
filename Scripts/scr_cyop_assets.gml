// Reset all CYOP asset maps
function cyop_assets_reset()
{
	var sprmap = ds_map_find_first(global.cyop_sprites)
	while (sprmap != undefined)
	{
		sprite_delete(ds_map_find_value(global.cyop_sprites, sprmap))
		sprmap = ds_map_find_next(global.cyop_sprites, sprmap)
	}
	
	ds_map_clear(global.cyop_sprites)
	ds_map_clear(global.cyop_tilesets)
}

// Load sprites from current CYOP tower
function cyop_assets_load()
{
	// Add sprites in root of folder
	var spritesfile = file_find_first(concat(cyop_get_tower_dir(), "sprites/*.png"), 0)
	
	while (spritesfile != "")
	{
		cyop_assets_add_sprite(concat(cyop_get_tower_dir(), "sprites/"), spritesfile)
		spritesfile = file_find_next()
	}
	
	file_find_close()
	
	if (global.cyop_preload)
	{
		// Get all subfolders and then add the sprites in said folders
		var folders = file_find_first(concat(cyop_get_tower_dir(), "sprites/*"), fa_directory)
		var folder_list = ds_list_create()
	
		while (folders != "")
		{
			ds_list_add(folder_list, folders)
			folders = file_find_next()
		}
	
		file_find_close()
		
		for (var i = 0; i < ds_list_size(folder_list); i++)
		{
			var folderspritesfile = file_find_first(concat(cyop_get_tower_dir(), "sprites/", ds_list_find_value(folder_list, i), "/*.png"), 0)
	
			while (folderspritesfile != "")
			{
				cyop_assets_add_sprite(concat(cyop_get_tower_dir(), "sprites/", ds_list_find_value(folder_list, i), "/"), folderspritesfile)
				folderspritesfile = file_find_next()
			}
	
			file_find_close()
		}
	}
}

// Add specified sprite from folder
///@param directory
///@param sprite_file
function cyop_assets_add_sprite(_dir, _sprfile)
{
	var sprite_name = string_replace(_sprfile, ".png", "")
	var ini_name = string_replace(_sprfile, ".png", ".ini")
	
	var spr_offset = [0, 0]
	var spr_centered = false
	var spr_frames = 1
	var spr_width = 0
	
	var tile_size = 0
	var tile_scale = 1
	
	if (file_exists(_dir + ini_name))
	{
		ini_open(_dir + ini_name)
		
		spr_offset = [ini_read_real("offset", "x", 0), ini_read_real("offset", "y", 0)]
		spr_centered = ini_read_real("offset", "centered", false)
		spr_frames = ini_read_real("properties", "images", 1)
		spr_width = ini_read_real("properties", "image_width", 0)
		
		tile_size = abs(ini_read_real("tileset", "size", 0))
		if (tile_size != 0)
			tile_scale = 32 / tile_size
		
		ini_close()
	}
	
	if (spr_width > 0)
	{
		var widthcheck_spr = sprite_add(_dir + _sprfile, 1, false, false, 0, 0)
		spr_frames = sprite_get_width(widthcheck_spr) / spr_width
		sprite_delete(widthcheck_spr)
	}
	
	var spr_index = sprite_add(_dir + _sprfile, spr_frames, false, false, 0, 0)
	
	sprite_set_speed(spr_index, 1, spritespeed_framespergameframe)
	if (spr_centered)
	{
		spr_offset[0] += sprite_get_width(spr_index) / 2
		spr_offset[1] += sprite_get_height(spr_index) / 2
	}
	sprite_set_offset(spr_index, spr_offset[0], spr_offset[1])

	ds_map_replace(global.cyop_sprites, sprite_name, spr_index)
	
	if (tile_size != 0)
		cyop_assets_add_tileset(sprite_name, tile_size, tile_scale)
	
	return sprite_name;
}

// Add tileset data for tileset sprite
///@param sprite_name
///@param size
///@param scale
function cyop_assets_add_tileset(_spr_name, _size, _scale)
{
	ds_map_replace(global.cyop_tilesets, _spr_name,
	{
		size : _size,
		scale : _scale,
	})
}

// Get tileset data
function cyop_assets_get_tileset(_name)
{
	if (ds_map_exists(global.cyop_tilesets, _name))
		return ds_map_find_value(global.cyop_tilesets, _name);
	else
	{
		return
		{
			size : 32,
			scale : 1,
		};
	}
}

// Get CYOP room music
function cyop_assets_get_music()
{
	var _music = global.cyop_roomdata.properties.song
	
	// Get the song name from the music map
	var music_names = variable_struct_get_names(global.cyop_musicmap)
	for (var i = 0; i < array_length(music_names); i++)
	{
		if (_music == music_names[i])
			_music = variable_struct_get(global.cyop_musicmap, _music)
	}
	
	return _music;
}

// Check if music string is an FMOD event
function cyop_assets_is_event(_music)
{
	return (string_pos("event:", _music));
}