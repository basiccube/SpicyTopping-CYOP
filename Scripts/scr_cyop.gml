// Sets the current CYOP tower folder
function cyop_set_directory()
{
	// Check if CYOP towers from regular PT are present
	// and use those instead
	var directoryToCheck = environment_get_variable("APPDATA") + "\\PizzaTower_GM2\\towers"
	if directory_exists(directoryToCheck)
		return directoryToCheck;
	
	return "towers";
}

// Get installed towers
function cyop_get_towers()
{
	var towerfolder = file_find_first(global.cyop_towerdir + "/*", fa_directory)
	ds_list_clear(towerList)
	
	while (towerfolder != "")
	{
		ds_list_add(towerList, { towerName : towerfolder })
		towerfolder = file_find_next()
	}
	
	file_find_close()
}

// Get info for specified tower
function cyop_get_tower_info(tower_name)
{
	towerfile = file_find_first(global.cyop_towerdir + "/" + tower_name + "/*.ini", 0)
	while (string_pos("tower.ini", towerfile) == 0 && towerfile != "")
		towerfile = file_find_next()
	file_find_close()
		
	trace("Tower file name: ", towerfile)
	if (string_pos("tower.ini", towerfile) != 0)
	{
		ini_open(global.cyop_towerdir + "/" + tower_name + "/" + towerfile)
		
		var infostruct =
		{
			name : ini_read_string("properties", "name", ""),
			mainlevel : ini_read_string("properties", "mainlevel", ""),
			type : ini_read_real("properties", "type", 0),
		}
		
		ini_close()
		
		return infostruct;
	}
	
	return -4;
}

// Get current tower directory
function cyop_get_tower_dir()
{
	return global.cyop_towerdir + "/" + global.cyop_tower + "/";
}

// Get directory of current level from tower
function cyop_get_level_dir()
{
	return cyop_get_tower_dir() + "levels/" + global.cyop_level + "/";
}

// Get info for current level
function cyop_get_level_info()
{
	ini_open(cyop_get_level_dir() + "level.ini")
	
	var level_info =
	{
		name : ini_read_string("data", "name", ""),
		pscore : ini_read_real("data", "pscore", 0),
		escapetime : ini_read_real("data", "escape", 210),
		hubworld : ini_read_real("data", "isWorld", 0),
	}
	
	ini_close()
	
	return level_info;
}

// Get room data from room in current level
function cyop_get_level_roomdata()
{
	// String pointing to the room file
	// If room file thats for AFOM exists, use that instead
	var roomfile = cyop_get_level_dir() + "rooms/" + global.cyop_levelroom + ".json"
	if (file_exists(cyop_get_level_dir() + "rooms/" + global.cyop_levelroom + "_wfixed.json") && global.cyop_afom)
		roomfile = cyop_get_level_dir() + "rooms/" + global.cyop_levelroom + "_wfixed.json"
	
	// Cool, gonna do anything if the room is missing?
	// No? Okay then.
	if !file_exists(roomfile)
		show_message("ERROR: " + global.cyop_level + " room " + global.cyop_levelroom + " missing!")
	
	// Get room data from room file
	var file = file_text_open_read(roomfile)
	var filestr = file_text_read_all(file)
	var roomjson = json_parse(filestr)
	file_text_close(file)
	
	// The object map that will be used for the object indices (if the objects don't use names)
	// If the room was made using a version of CYOP made for the Noise Update,
	// then use the AFOM/Noise Update object map
	var objectmap = global.cyop_objectmap
	if (variable_struct_exists(roomjson, "isNoiseUpdate") && roomjson.isNoiseUpdate)
		objectmap = global.cyop_afomobjectmap
	
	// Fixes for older CYOP versions
	// Could probably be better than whatever this is
	if (roomjson.editorVersion < 6)
	{
		var room_instances = roomjson[$ "instances"]
		for (i = 0; i < array_length(room_instances); i++)
		{
			var instance_obj = room_instances[i].object
			if (instance_obj <= array_length(objectmap))
			{
				room_instances[i].object = asset_get_index(objectmap[instance_obj])
				if (room_instances[i].object == -1)
					warn("Missing object! - ", objectmap[instance_obj])
					
				var objvariables = room_instances[i][$ "variables"]
				if (variable_struct_exists(objvariables, "content"))
				{
					var contentvar = objvariables[$ "content"]
					if (!is_string(objvariables[$ "content"]))
					{
						if (is_array(contentvar))
						{
							for (ii = 0; ii < array_length(contentvar); ii++)
							{
								if (is_struct(contentvar[ii]))
									continue;
								
								var original_index = contentvar[ii]
								contentvar[ii] = asset_get_index(objectmap[contentvar[ii]])
								if (contentvar[ii] == -1)
									warn("Missing object! - ", objectmap[original_index])
							}
						}
						else
						{
							contentvar = asset_get_index(objectmap[contentvar])
							if (contentvar == -1)
								warn("Missing object! - ", objectmap[contentvar])
						}
					}
					else
						contentvar = asset_get_index(objvariables[$ "content"])
						
					if (contentvar == -1)
						warn("Missing object! - ", objvariables[$ "content"])
					
					objvariables[$ "content"] = contentvar
				}
			}
		}
		
		switch roomjson.editorVersion
		{
			case 0:
				var _bgnames = variable_struct_get_names(roomjson.backgrounds)
				for (var i = 0; i < array_length(_bgnames); i++)
				{
					var _bg = variable_struct_get(roomjson.backgrounds, _bgnames[i])
					if (!variable_struct_exists(_bg, "hspeed"))
					{
						variable_struct_set(_bg, "hspeed", 0)
						variable_struct_set(_bg, "vspeed", 0)
					}
				}
			case 1:
				variable_struct_set(roomjson.properties, "song", "")
			case 2:
				variable_struct_set(roomjson.properties, "songTransitionTime", 100)
			case 3:
				var _bgnames = variable_struct_get_names(roomjson.backgrounds)
				for (var i = 0; i < array_length(_bgnames); i++)
				{
					var _bg = variable_struct_get(roomjson.backgrounds, _bgnames[i])
					if (!variable_struct_exists(_bg, "image_speed"))
					{
						variable_struct_set(_bg, "image_speed", 15)
						variable_struct_set(_bg, "panic_sprite", -1)
					}
				}
				break
		}
	
		roomjson.editorVersion = global.cyopversion
	}
	else
	{
		var room_instances = roomjson[$ "instances"]
		for (i = 0; i < array_length(room_instances); i++)
		{
			var original_objname = room_instances[i].object
			room_instances[i].object = asset_get_index(room_instances[i].object)
			if (room_instances[i].object == -1)
				warn("Missing object! - ", original_objname)
					
			var objvariables = room_instances[i][$ "variables"]
			if (variable_struct_exists(objvariables, "content"))
			{
				var original_contentname = objvariables[$ "content"]
				var contentvar = objvariables[$ "content"]
				if (is_array(contentvar))
				{
					for (ii = 0; ii < array_length(contentvar); ii++)
					{
						if (is_struct(contentvar[ii]))
							continue;
						
						if (!is_string(contentvar[ii]))
						{
							var original_index = contentvar[ii]
							contentvar[ii] = asset_get_index(objectmap[contentvar[ii]])
							if (contentvar[ii] == -1)
								warn("Missing object! - ", objectmap[original_index])
						}
						else
						{
							original_contentname = contentvar[ii]
							contentvar[ii] = asset_get_index(contentvar[ii])
							if (contentvar[ii] == -1)
								warn("Missing object! - ", original_contentname)
						}
					}
				}
				else
				{
					if (!is_string(contentvar))
					{
						contentvar = asset_get_index(objectmap[contentvar])
						if (contentvar == -1)
							warn("Missing object! - ", objectmap[contentvar])
					}
					else
						contentvar = asset_get_index(contentvar)
				}
						
				if (contentvar == -1)
					warn("Missing object! - ", original_contentname)
					
				objvariables[$ "content"] = contentvar
			}
		}
	}
	
	return roomjson;
}

// Go to rm_cyoplevel and load the room in there
function cyop_goto_level()
{
	var _data = global.cyop_roomdata
	room_set_width(rm_cyoplevel, _data.properties.levelWidth - _data.properties.roomX)
	room_set_height(rm_cyoplevel, _data.properties.levelHeight - _data.properties.roomY)
	
	room_goto(rm_cyoplevel)
}

enum valuetype
{
	sprite,
	text,
	room,
}

// Replace value if needed
///@param var_value
///@param value_type
function cyop_get_value(_val, _overridetype = -4)
{
	if (is_string(_val) && _overridetype != valuetype.room && _overridetype != valuetype.text)
	{
		switch _val
		{
			case "true":
				return true;
				break
			case "false":
				return false;
				break
		}
		
		if (string_pos("/", _val) != 0 && global.cyop_preload)
		{
			split_arr = string_split(_val, "/")
			_val = split_arr[array_length(split_arr) - 1]
		}
		
		if (ds_map_exists(global.cyop_sprites, _val))
			return ds_map_find_value(global.cyop_sprites, _val);
		else
		{
			var _spritesfile = file_find_first(concat(cyop_get_tower_dir(), "sprites/", _val, ".png"), 0)
			if (_spritesfile != "")
			{
				cyop_assets_add_sprite(concat(cyop_get_tower_dir(), "sprites/"), concat(_val, ".png"))
					
				with (obj_savesystem)
				{
					showicon = true
					icon_alpha = 2
				}
			}
			file_find_close()
			
			if (ds_map_exists(global.cyop_sprites, _val))
				return ds_map_find_value(global.cyop_sprites, _val);
		}
		
		// Why do these use _i instead of just i for the variable?
		
		// Several tilesets in Spicy Topping have been renamed,
		// so this needs to be done
		var tileset_names = variable_struct_get_names(global.cyop_tilesetmap)
		for (var _i = 0; _i < array_length(tileset_names); _i++)
		{
			if (_val == tileset_names[_i])
				_val = variable_struct_get(global.cyop_tilesetmap, _val)
		}
		
		var sprite_names = variable_struct_get_names(global.cyop_spritemap)
		for (var _i = 0; _i < array_length(sprite_names); _i++)
		{
			if (_val == sprite_names[_i])
				_val = variable_struct_get(global.cyop_spritemap, _val)
		}
			
		var _assetindex = asset_get_index(_val)
		if (_assetindex != -1)
		{
			if (asset_get_type(_val) != asset_sprite && _overridetype == valuetype.sprite)
				return spr_null;
			
			return _assetindex;
		}
		else if (_overridetype == valuetype.sprite)
			return spr_null;
	}
	
	return _val;
}

// Draw CYOP tile
///@param tileset
///@param coords
///@param tileX
///@param tileY
///@param scale
function cyop_draw_tile(_tileset, _coord, _tileX, _tileY, _scale = 1)
{
	if (array_length(_coord) == 2)
		_coord = [_coord[0], _coord[1], 1, 1]
		
	var _tilesetinfo = cyop_assets_get_tileset(_tileset)
	var _tilesetspr = cyop_get_value(_tileset)
	
	if (is_string(_tilesetspr))
		exit;
	
	draw_sprite_part_ext(_tilesetspr,
						0,
						_coord[0] * _tilesetinfo.size,
						_coord[1] * _tilesetinfo.size,
						_tilesetinfo.size * _coord[2],
						_tilesetinfo.size * _coord[3],
						_tileX,
						_tileY,
						_tilesetinfo.scale * _scale,
						_tilesetinfo.scale * _scale,
						draw_get_color(),
						draw_get_alpha())
}

// Check if tile layer is meant to be a secret tile layer
///@param layer
function cyop_is_secrettile(_layer)
{
	return (_layer <= -5);
}

// Check if tile layer shouldn't be affected when breaking destroyables
///@param layer
function cyop_is_unbreakabletile(_layer)
{
	return (_layer >= 11 && _layer <= 15);
}

// Initialize CYOP tile layer
///@param layer
///@param tile_data
function cyop_init_tilelayer(_layer, _tile_data)
{
	if (!layer_exists(concat("Tiles_", _layer)))
	{
		if (real(_layer) >= 0)
			layer_create(real(_layer) * 5, concat("Tiles_", _layer))
		else
			layer_create(real(_layer) - 100, concat("Tiles_", _layer))
	}
		
	with (obj_CYOPTileHandler)
	{
		if (layer_get_name(layer) == concat("Tiles_", _layer))
		{
			tilemap_layer = _layer
			tileHandler_init(variable_struct_get(_tile_data, _layer))
			exit;
		}
	}
	
	with (instance_create_layer(0, 0, concat("Tiles_", _layer), obj_CYOPTileHandler))
	{
		tilemap_layer = _layer
		tileHandler_init(variable_struct_get(_tile_data, _layer))
	}
}

// Initialize CYOP background layer
///@param layer
///@param bg_data
function cyop_init_bglayer(_layer, _bg_data)
{
	if (!layer_exists(concat("Backgrounds_", _layer)))
	{
		if (real(_layer) < 0)
			layer_create((real(_layer) * 10 + 500) * -1, concat("Backgrounds_", _layer))
		else
			layer_create(real(_layer) * 10 + 500, concat("Backgrounds_", _layer))
	}
		
	with (obj_CYOPBGHandler)
	{
		if (bgLayer == _layer)
			instance_destroy()
	}
	
	with (instance_create_layer(0, 0, concat("Backgrounds_", _layer), obj_CYOPBGHandler))
	{
		bgLayer = _layer
		bgHandler_init(variable_struct_get(_bg_data, _layer))
	}
}

// Delete tile from CYOP tile handlers
///@param x
///@param y
function cyop_tilemap_delete_tile(_x, _y)
{
	with (obj_CYOPTileHandler)
	{
		if (!cyop_is_secrettile(tilemap_layer) && !cyop_is_unbreakabletile(tilemap_layer))
			tileHandler_deleteTile(_x, _y)
	}
}

// Delete multiple tiles from CYOP tile handlers
///@param tile_size
///@param offset
function cyop_tilemap_delete_tiles(_tile_size, _offset = 0)
{
	// This is just a copy of scr_destroy_tiles...
	var w = abs(sprite_width) / _tile_size
	var h = abs(sprite_height) / _tile_size
	var ix = sign(image_xscale)
	var iy = sign(image_yscale)
	
	if (ix < 0)
		w++
	
	for (var yy = 0 - _offset; yy < h + _offset; yy++)
	{
		for (var xx = 0 - _offset; xx < w + _offset; xx++)
			cyop_tilemap_delete_tile(x + ((xx * _tile_size) * ix), y + ((yy * _tile_size) * iy))
	}
}

// Reset some player sounds since these sometimes break in Spicy Topping
function cyop_reset_playersounds()
{
	if fmod_is_playing(snd_mach)
		fmod_stop(snd_mach, true)
	if fmod_is_playing(snd_machnoise)
		fmod_stop(snd_machnoise, true)
	if fmod_is_playing(snd_divebomb)
		fmod_stop(snd_divebomb, true)
	if fmod_is_playing(snd_wallbounce)
		fmod_stop(snd_wallbounce, true)
	if fmod_is_playing(snd_airspin)
		fmod_stop(snd_airspin, true)
	if fmod_is_playing(snd_superjump)
		fmod_stop(snd_superjump, true)
	if fmod_is_playing(snd_superjumpnoise)
		fmod_stop(snd_superjumpnoise, true)
}