draw_set_font(lang_get_font("bigfont"))
draw_set_halign(fa_left)
draw_set_valign(fa_top)

var showModifiers = false
if (ds_list_size(towerList) > 0)
{
	draw_sprite(spr_cursor, cursor_index, cursor_x, cursor_y)
	for (var i = 0; i < ds_list_size(towerList); i++)
	{
		var towerData = ds_list_find_value(towerList, i)
		var vi = i % maxtowers
		var vmin = maxtowers * (selection div maxtowers)
		var vmax = maxtowers * ((selection div maxtowers) + 1)
		var a = 0.5
		if (selection == i)
		{
			a = 1
			if (towerData.towerInfo.type == 1)
				showModifiers = true
		}
		
		if (i >= vmin && i < vmax)
		{
			if (towerData.towerInfo.type == 0)
				draw_sprite(spr_cyop_icon_tower, 0, menu_x + 56, menu_y + (36 * vi))
			draw_text_color(menu_x + 84, menu_y - 16 + (36 * vi), string_upper(towerData.towerInfo.name), c_white, c_white, c_white, c_white, a)
		}
	}
}

draw_set_font(lang_get_font("smallfont2"))
var currpage = (selection div maxtowers) + 1
var maxpage = ((ds_list_size(towerList) - 1) div maxtowers) + 1
draw_text_color(12, SCREEN_HEIGHT - 24, string(currpage) + "/" + string(maxpage), c_white, c_white, c_white, c_white, 1)

draw_set_halign(fa_right)
draw_text_color(SCREEN_WIDTH - 8, SCREEN_HEIGHT - 24, "Press " + scr_keyname(global.key_attack) + " to open towers folder", c_white, c_white, c_white, c_white, 1)

if showModifiers
	draw_text_color(SCREEN_WIDTH - 8, SCREEN_HEIGHT - 48, "Press " + scr_keyname(global.key_taunt) + " for modifiers", c_white, c_white, c_white, c_white, 1)

if (directoryopen)
{
	draw_set_alpha(0.5)
	draw_rectangle_color(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, c_black, c_black, c_black, c_black, false)
	draw_set_alpha(1)
	
	draw_set_halign(fa_center)
	draw_text_color(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, "A file browser window should have opened.\n\nPress any key to close and refresh the tower list.", c_white, c_white, c_white, c_white, 1)
}

with (obj_modifiermenu)
	event_perform(ev_draw, ev_gui)

if (!fadeout)
	exit;
	
draw_set_alpha(fadealpha)
draw_set_color(c_black)
draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false)
draw_set_alpha(1)