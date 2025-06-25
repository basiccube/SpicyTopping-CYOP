if global.cyophidebg
	exit;

x += hsp
y += vsp
bgIndex += bgSpeed / 60

var camX = camera_get_view_x(view_camera[0])
var camY = camera_get_view_y(view_camera[0])

if !is_string(bgSprite)
{
	var _dx = x + bgX + camX * (1 - scrollX)
	var _dy = y + bgY + camY * (1 - scrollY)
	
	// I think this function was from CYOP originally
	draw_sprite_tiled_direction(bgSprite, bgIndex % sprite_get_number(bgSprite), _dx, _dy, tileX, tileY)
}