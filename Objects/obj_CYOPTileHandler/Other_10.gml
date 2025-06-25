///@description Update Tiles
tileHandler_updateCameraInfo()

var cam_scale = camera_get_view_width(view_camera[0]) / SCREEN_WIDTH

var lCamSeamX = camseamX
var lCamSeamY = camseamY

var camXDiff = drawX[0] - camseamX
var camYDiff = drawY[0] - camseamY

if (abs(camXDiff) > SCREEN_WIDTH / 2 || abs(camYDiff) > SCREEN_HEIGHT / 2)
{
	tileHandler_init(tilemap)
    exit;
}

camseamX += camXDiff
camseamY += camYDiff

if (verStall[0] == 0)
{
    seamX[0] += sign(xDiff[0]) * 32
    seamSaveY[0] = drawY[0]
    seamX[0] = clamp(seamX[0], drawX[0], drawX[1])
    xDiff[0] = drawX[0] - seamX[0]
}
if (verStall[1] == 0)
{
    seamX[1] += sign(xDiff[1]) * 32
    seamSaveY[1] = drawY[1]
    seamX[1] = clamp(seamX[1], drawX[0], drawX[1])
    xDiff[1] = drawX[1] - seamX[1]
}

if (horStall[0] == 0)
{
    seamY[0] += sign(yDiff[0]) * 32
    seamSaveX[0] = drawX[0]
    seamY[0] = clamp(seamY[0], drawY[0], drawY[1])
    yDiff[0] = drawY[0] - seamY[0]
}
if (horStall[1] == 0)
{
    seamY[1] += sign(yDiff[1]) * 32
    seamSaveX[1] = drawX[1]
    seamY[1] = clamp(seamY[1], drawY[0], drawY[1])
    yDiff[1] = drawY[1] - seamY[1]
}

if (lCamSeamX != camseamX || lCamSeamY != camseamY)
{
	tileHandler_updateOldSurface()
	
	surface_set_target(tilemap_surface)
	draw_clear_alpha(c_black, 0)
	draw_surface(tilemap_oldsurface, -camXDiff / cam_scale, -camYDiff / cam_scale)
	surface_reset_target()
}

surface_set_target(tilemap_surface)

var horStallReset = [true, true]
var verStallReset = [true, true]

for (var i = 0; i < 2; i++)
{
	if (xDiff[i] * (1 - i * 2) < 0)
	{
		var off = verStall[i]
		var stallMax = 1024 + seam_size * 128
		var stop = false
		var adv = 0
		var pos = [seamX[i], seamSaveY[0] + off]
		
		if (verStall[i] != 0 && pos[1] != lastFinishY[i])
            off -= pos[1] - lastFinishY[i]
			
		for (ii = seamSaveY[0] + off; ii < seamSaveY[1] + 32 && !stop; ii += 32)
        {
            if (adv > stallMax)
            {
                verStall[i] += adv
                verStallReset[i] = false
                stop = true
                lastFinishY[i] = seamSaveY[0] + verStall[i]
            }
            else
            {
                adv += 32
                var pos = [seamX[i], ii]
                    
                var posString = string(int64(pos[0] + room_x - x)) + "_" + string(int64(pos[1] + room_y - y))
                    
				if (variable_struct_exists(tilemap, posString))
				{
					if (!variable_struct_exists(tilesDeleted, posString))
					{
						var spr = variable_struct_get(tilemap, posString).tileset
						var coord = variable_struct_get(tilemap, posString).coord
						cyop_draw_tile(spr, coord, (pos[0] - camseamX) / cam_scale, (pos[1] - camseamY) / cam_scale, 1 / cam_scale)
					}
				}
            }
        }
	}
}

for (var i = 0; i < 2; i++)
{
	if (yDiff[i] * (1 - i * 2) < 0)
	{
		var off = horStall[i]
		var stallMax = 1024 + seam_size * 128
		var stop = false
		var adv = 0
		var pos = [seamSaveX[0] + off, seamY[i]]
		
		if (horStall[i] != 0 && pos[0] != lastFinishX[i])
			off -= pos[0] - lastFinishX[i]
			
		for (ii = seamSaveX[0] + off; ii < seamSaveX[1] + 32 && !stop; ii += 32)
        {
            if (adv > stallMax)
            {
                horStall[i] += adv
				horStallReset[i] = false
				stop = true
				var pos = [ii, seamY[i]]
                    
				lastFinishX[i] = seamSaveX[0] + horStall[i]
            }
            else
            {
                adv += 32;
				var pos = [ii, seamY[i]]
				var posString = string(int64(pos[0] + room_x - x)) + "_" + string(int64(pos[1] + room_y - y));
                    
				if (variable_struct_exists(tilemap, posString))
				{
					if (!variable_struct_exists(tilesDeleted, posString))
					{
						var spr = variable_struct_get(tilemap, posString).tileset
						var coord = variable_struct_get(tilemap, posString).coord
						cyop_draw_tile(spr, coord, (pos[0] - camseamX) / cam_scale, (pos[1] - camseamY) / cam_scale, 1 / cam_scale)
					}
				}
            }
        }
	}
}

if (horStallReset[0])
	horStall[0] = 0
if (horStallReset[1])
	horStall[1] = 0
if (verStallReset[0])
	verStall[0] = 0
if (verStallReset[1])
	verStall[1] = 0

surface_reset_target()
