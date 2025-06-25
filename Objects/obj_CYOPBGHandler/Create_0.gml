bgLayer = 0
bgX = 0
bgY = 0
scrollX = 1
scrollY = 1
tileX = true
tileY = true
bgIndex = 0
bgSpeed = 0

// I don't think this function that is used once is needed
function bgHandler_init(_bgdata)
{
	bgSprite = cyop_get_value(_bgdata.sprite)
	if is_string(bgSprite)
		warn("Missing background: ", bgSprite)
	
	bgX = _bgdata.x
	bgY = _bgdata.y
	scrollX = _bgdata.scroll_x
	scrollY = _bgdata.scroll_y
	tileX = _bgdata.tile_x
	tileY = _bgdata.tile_y
	hsp = _bgdata.hspeed
	vsp = _bgdata.vspeed
	bgSpeed = _bgdata.image_speed
}