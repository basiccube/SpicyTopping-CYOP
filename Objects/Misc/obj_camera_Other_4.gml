x = obj_player1.x
y = obj_player1.y

var cam_width = camera_get_view_width(view_camera[0])
var cam_height = camera_get_view_height(view_camera[0])
var cam_x = (obj_player1.x - (cam_width / 2))
var cam_y = ((obj_player1.y - (cam_height / 2)) - 50)

cam_x = clamp(cam_x, 0, room_width - cam_width)
cam_y = clamp(cam_y, 0, room_height - cam_height)
smoothcam_x = cam_x
smoothcam_y = cam_y

with (obj_camera)
{
	shake_mag = 0
	shake_mag_acc = 0
}

if global.coop
	camera_zoom(1)

if (global.panic && global.panicbg)
	panicbg_init()

// CYOP code here
// hubworld variable is for disabling the HUD
hubworld = false
if (global.cyop && room == rm_cyoplevel)
{
	level_info = cyop_get_level_info()
	if (level_info.hubworld || global.cyop_level == global.cyop_hublevel)
	{
		hubworld = true
		with (obj_player1)
			backtohubroom = rm_cyopmenu
	}
}