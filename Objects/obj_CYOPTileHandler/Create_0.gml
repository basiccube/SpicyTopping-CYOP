room_x = 0
room_y = 0

function tileHandler_init(_tilemap)
{
	tilemap = _tilemap
	tiles = variable_struct_get_names(_tilemap)
	room_x = global.cyop_roomdata.properties.roomX
	room_y = global.cyop_roomdata.properties.roomY
	
	tileHandler_checkSurfaces()
	
	if (alarm[0] > -1)
		exit;
	
	alarm[0] = 2
}

function tileHandler_checkSurfaces()
{
	var maxsize = 16384
	var surfaceW = SCREEN_WIDTH + (seam_size + 1) * 2 * 32
	var surfaceH = SCREEN_HEIGHT + (seam_size + 1) * 2 * 32
	
	if (seam_mode == 1)
	{
		surfaceW = clamp(global.cyop_roomdata.properties.levelWidth - room_x, 0, maxsize)
		surfaceH = clamp(global.cyop_roomdata.properties.levelHeight - room_y, 0, maxsize)
	}
	
	var createsurf = false
	if !surface_exists(tilemap_surface)
		createsurf = true
	else
	{
		surface_set_target(tilemap_surface)
		draw_clear_alpha(c_black, 0)
		surface_reset_target()
		
		if (surface_get_width(tilemap_surface) != surfaceW || surface_get_height(tilemap_surface) != surfaceH)
		{
			surface_free(tilemap_surface)
			createsurf = true
		}
	}
	
	if !surface_exists(tilemap_oldsurface)
		createsurf = true
	
	if createsurf
	{
		if (surface_exists(tilemap_surface))
			surface_free(tilemap_surface)
		tilemap_surface = surface_create(surfaceW, surfaceH)
		
		if (surface_exists(tilemap_oldsurface))
			surface_free(tilemap_oldsurface)
		tilemap_oldsurface = surface_create(surfaceW, surfaceH)
		
		array_push(global.cyop_surfaceend, tilemap_surface)
		array_push(global.cyop_surfaceend, tilemap_oldsurface)
	}
}

function tileHandler_updateCameraInfo()
{
	camX = camera_get_view_x(view_camera[0])
	camY = camera_get_view_y(view_camera[0])
	
	camW = camera_get_view_width(view_camera[0])
	camH = camera_get_view_height(view_camera[0])
	
	drawX = [(floor(camX / 32) - seam_size) * 32, (floor((camX + camW) / 32) + seam_size) * 32]
    drawY = [(floor(camY / 32) - seam_size) * 32, (floor((camY + camH) / 32) + seam_size) * 32]
	
	if (camW < 960)
	{
		drawX[1] += -seam_size * 32 + 32
        drawY[1] += -seam_size * 32
	}
}

function tileHandler_updateOldSurface()
{
	surface_set_target(tilemap_oldsurface)
	draw_clear_alpha(c_black, 0)
	draw_surface(tilemap_surface, 0, 0)
	surface_reset_target()
}

function tileHandler_update()
{
	if (surface_exists(tilemap_surface) && surface_exists(tilemap_oldsurface))
		event_user(0)
}

///@param x
///@param y
function tileHandler_deleteTile(_x, _y)
{
	var dx = _x - camseamX
    var dy = _y - camseamY
	
    surface_set_target(tilemap_surface)
    gpu_set_blendmode(bm_subtract)
    draw_set_color(c_black)
    draw_rectangle(dx, dy, dx + 32, dy + 32, false)
    draw_set_color(c_white)
    gpu_set_blendmode(bm_normal)
    surface_reset_target()
	
	var posString = string(_x + room_x) + "_" + string(_y + room_y)
	variable_struct_set(tilesDeleted, posString, "deleted")
}

tilemap = -4
tilemap_surface = -1
tilemap_oldsurface = -1
tilemap_layer = 0
tile_alpha = 1
tiles = []
tilesDeleted = {}

seamX = [0, 0]
seamY = [0, 0]
camseamX = 0
camseamY = 0
seamSaveX = [0, 0]
seamSaveY = [0, 0]
seam_mode = 0
seam_size = 4
seam_ready = false
lastFinishX = [undefined, undefined]
lastFinishY = [undefined, undefined]

xDiff = [0, 0]
yDiff = [0, 0]
horStall = [0, 0]
verStall = [0, 0]