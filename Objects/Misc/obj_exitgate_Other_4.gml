if (ds_list_find_index(global.saveroom, id) != -1 && global.panic == false)
	image_index = 0

if (ds_list_find_index(global.baddieroom, id) != -1 && drop)
{
	y = drop_y
	dropstate = states.idle
	hand_y = -100
}
random_secret = instance_exists(obj_randomsecret) && obj_randomsecret.start

if global.solidbreak
{
	with (instance_create(bbox_left, bbox_bottom, obj_dynamicPlatform))
	{
		depth = 100
		image_xscale = other.sprite_width / 32
	}
}

// CYOP code here
if (global.cyop && !global.panic)
{
	level_info = cyop_get_level_info()
	
	global.srank = floor(level_info.pscore)
	global.minutes = floor(level_info.escapetime / 60)
	global.seconds = floor(level_info.escapetime % 60)
}

if (global.reversemode && global.reversemodestarted && !reversestart)
{
	instance_destroy(id, false)
	if (!global.panic)
	{
		with (instance_create(x, y + 16, obj_hungrypillar))
		{
			reverseend = true
			
			switch room
			{
				case medieval_1:
				case ruin_1:
					image_xscale *= -1
					break
			}
		}
		with (obj_music)
		{
			fmod_play_instance(pillarmusic)
			fmod_set_global("pillarfade", 0, true)
		}
	}
}

if (global.reversemode && !global.reversemodestarted)
{
	var endroom = -4
	switch room
	{
		case entrance_1:
			endroom = entrance_10
			global.minutes = 2
			global.seconds = 30
			break
		case medieval_1:
			endroom = medieval_10
			global.minutes = 2
			global.seconds = 45
			break
		case ruin_1:
			endroom = ruin_11
			global.minutes = 2
			global.seconds = 59
			break
		case dungeon_1:
			endroom = dungeon_10
			global.minutes = 4
			global.seconds = 30
			break
		case chateau_1:
			endroom = chateau_9
			global.minutes = 3
			global.seconds = 15
			instance_create(obj_player1.x, obj_player1.y, obj_trapghost)
			break
		case strongcold_1:
			endroom = strongcold_john
			global.minutes = 2
			global.seconds = 59
			break
		case badland_1:
			endroom = badland_9
			global.minutes = 2
			global.seconds = 45
			break
		case graveyard_1:
			endroom = graveyard_6
			global.minutes = 2
			global.seconds = 45
			break
		case farm_2:
			endroom = farm_11
			global.minutes = 3
			global.seconds = 25
			break
		case saloon_1:
			endroom = saloon_6
			global.minutes = 2
			global.seconds = 30
			break
		case plage_entrance:
			endroom = plage_cavern2
			global.minutes = 2
			global.seconds = 45
			break
		case forest_1:
			endroom = forest_john
			global.minutes = 4
			global.seconds = 10
			execute_delayed_function(function()
			{
				with (obj_player1)
				{
					brick = true
					isgustavo = true
				}
			}, 0)
			with (obj_player1)
				isgustavo = true
			break
		case minigolf_1:
			endroom = minigolf_8
			global.minutes = 3
			global.seconds = 30
			break
		case space_1:
			endroom = space_9
			global.minutes = 2
			global.seconds = 30
			break
		case sewer_1:
			endroom = sewer_8
			global.minutes = 4
			global.seconds = 10
			break
		case freezer_1:
			endroom = freezer_escape1
			global.minutes = 3
			global.seconds = 50
			global.noisejetpack = true
			break
		case industrial_1:
			endroom = industrial_5
			global.minutes = 2
			global.seconds = 50
			break
		case street_intro:
			endroom = street_john
			global.minutes = 2
			global.seconds = 59
			execute_delayed_function(function()
			{
				with (obj_player1)
				{
					brick = true
					isgustavo = true
				}
			}, 0)
			with (obj_player1)
				isgustavo = true
			break
		case kidsparty_1:
			endroom = kidsparty_john
			global.minutes = 3
			global.seconds = 59
			execute_delayed_function(function()
			{
				with (obj_player1)
					shotgunAnim = true
			}, 0)
			with (obj_player1)
				shotgunAnim = true
			break
		case ice_1:
			endroom = ice_john
			global.minutes = 3
			global.seconds = 59
			break
	}
	
	if (endroom != -4 && room != endroom)
		room_goto_delayed(endroom, 0)
}