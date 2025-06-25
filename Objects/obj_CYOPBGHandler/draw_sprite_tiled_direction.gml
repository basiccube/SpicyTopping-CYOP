///@param sprite
///@param subimg
///@param x
///@param y
///@param tiledH
///@param tiledV
function draw_sprite_tiled_direction(_sprite, _index, _x, _y, _tiledH, _tiledV)
{
    var _spriteW = sprite_get_width(_sprite)
    var _spriteH = sprite_get_height(_sprite)
	
    if (_tiledH && _tiledV)
        draw_sprite_tiled(_sprite, _index, _x, _y)
    else
    {
        var cx = camera_get_view_x(view_camera[0])
        var cy = camera_get_view_y(view_camera[0])
        var cw = camera_get_view_width(view_camera[0])
        var ch = camera_get_view_height(view_camera[0])
        
        if (_tiledH)
        {
            while (_x < cx - _spriteW)
                _x += _spriteW
            while (_x > cx - _spriteW)
                _x -= _spriteW
			
            for (var i = _x; i < cx + cw + _spriteW; i += _spriteW)
                draw_sprite(_sprite, _index, i, _y)
        }
        else if (_tiledV)
        {
            while (_y < cy - _spriteH)
                _y += _spriteH
            while (_y > cy - _spriteH)
                _y -= _spriteH
			
            for (var i = _y; i < cy + ch + _spriteH; i += _spriteH)
                draw_sprite(_sprite, _index, _x, i)
        }
    }
	
    if (!_tiledH && !_tiledV)
        draw_sprite(_sprite, _index, _x, _y)
}