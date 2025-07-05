if global.cyophidebg
	exit;
if is_string(bgSprite)
	exit;
if (bgSprite == -4)
	exit;

x += hsp
y += vsp
bgIndex += bgSpeed / 60

var camX = camera_get_view_x(view_camera[0])
var camY = camera_get_view_y(view_camera[0])

var dx = x + bgX + (camX * (1 - scrollX))
var dy = y + bgY + (camY * (1 - scrollY))
draw_sprite_tiled_direction(bgSprite, bgIndex % sprite_get_number(bgSprite), dx, dy, tileH, tileV)