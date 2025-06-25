// Why not just use a stack instead of an array?
repeat (array_length(global.cyop_surfaceend))
{
	var surf = array_pop(global.cyop_surfaceend)
	if (surface_exists(surf))
		surface_free(surf)
}