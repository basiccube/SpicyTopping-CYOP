repeat ds_stack_size(global.cyop_surfaceStack)
{
	var surface = ds_stack_pop(global.cyop_surfaceStack)
	if surface_exists(surface)
		surface_free(surface)
}