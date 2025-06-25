if (is_undefined(tilemap))
	exit;
if (global.hidetiles)
	exit;
	
if (surface_exists(tilemap_surface) && surface_exists(tilemap_oldsurface))
{
	draw_set_alpha(1)
	event_user(0)
	
	draw_set_alpha(tile_alpha * image_alpha)
	tileHandler_updateCameraInfo()
	
	draw_surface_ext(tilemap_surface, drawX[0], drawY[0], 1, 1, 0, c_white, draw_get_alpha())
	draw_set_alpha(1)
}
else
{
	draw_set_alpha(1)
	tileHandler_init(tilemap)
}

draw_set_alpha(1)