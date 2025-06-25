// Reset CYOP instance manager
function cyop_instancemanager_reset()
{
	trace("CYOP Instance Manager reset")
	
	if (variable_global_exists("cyop_instancemanager") && ds_exists(global.cyop_instancemanager, ds_type_map))
		ds_map_clear(global.cyop_instancemanager)
	else
		global.cyop_instancemanager = ds_map_create()
	
	ds_list_clear(global.saveroom)
	ds_list_clear(global.baddieroom)
	ds_list_clear(global.escaperoom)
}

// Get string for an instance for use with the instance manager
///@param instance_id
function cyop_instancemanager_get(_instance_id)
{
	return global.cyop_levelroom + "_" + string(_instance_id);
}

// Add instance to instance manager
///@param instance_id
///@param instance
function cyop_instancemanager_add(_instance_id, _instance)
{
	ds_map_replace(global.cyop_instancemanager, _instance_id, _instance)
}

// Update instance manager with specified instance
///@param instance_id
///@param instance
function cyop_instancemanager_update(_instance_id, _instance)
{
	if ds_map_exists(global.cyop_instancemanager, _instance_id)
	{
		var inst = ds_map_find_value(global.cyop_instancemanager, _instance_id)
		
		var listind = ds_list_find_index(global.saveroom, inst)
		if (listind != -1)
			ds_list_replace(global.saveroom, listind, _instance)
			
		listind = ds_list_find_index(global.baddieroom, inst)
		if (listind != -1)
			ds_list_replace(global.baddieroom, listind, _instance)
			
		listind = ds_list_find_index(global.escaperoom, inst)
		if (listind != -1)
			ds_list_replace(global.escaperoom, listind, _instance)
	}
	
	cyop_instancemanager_add(_instance_id, _instance)
}