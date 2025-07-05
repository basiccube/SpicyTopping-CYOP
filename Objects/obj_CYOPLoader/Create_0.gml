roomdata = global.cyop_roomdata
if is_undefined(roomdata)
	exit;

global.cyop_surfaceStack = ds_stack_create()

// Look through all of the instances and set them up
for (var i = 0; i < array_length(roomdata.instances); i++)
{
	var instancedata = roomdata.instances[i]
	var instanceid = cyop_instancemanager_get(i)
	
	if (!instancedata.deleted && instancedata.object >= 0)
	{
		if (!layer_exists("Instances_" + string(instancedata.layer)))
			layer_create(-1 - instancedata.layer, "Instances_" + string(instancedata.layer))
			
		trace("Spawning instance: ", object_get_name(instancedata.object))
		
		var instance = instance_create_layer(instancedata.variables.x - roomdata.properties.roomX, instancedata.variables.y - roomdata.properties.roomY, "Instances_" + string(instancedata.layer), instancedata.object)
		if (instance_exists(instance))
		{
			cyop_instancemanager_update(instanceid, instance)
			
			instance.instID = i
			instance.flipX = false
			instance.flipY = false
			instance.targetRoom = "main"
			
			// Set up instance variables
			var instvariables = variable_struct_get_names(instancedata[$ "variables"])
			for (ii = 0; ii < array_length(instvariables); ii++)
			{
				var setvar = instvariables[ii]
				if (setvar != "x" && setvar != "y")
				{
					var newvalue = -4
					var spritevalue = false
					var spritename = instancedata.variables[$ setvar]
					if (setvar == "sprite_index" ||
						setvar == "bgsprite" ||
						setvar == "tv_spr" ||
						setvar == "particlespr" ||
						setvar == "spr_dead" ||
						setvar == "idlespr" ||
						setvar == "walkspr" ||
						setvar == "stunfallspr" ||
						setvar == "turnspr" ||
						setvar == "grabbedspr" ||
						setvar == "scaredspr")
						spritevalue = true
					
					if (spritevalue)
						newvalue = cyop_get_value(instancedata.variables[$ setvar], valuetype.sprite)
					else if (setvar == "targetRoom")
						newvalue = cyop_get_value(instancedata.variables[$ setvar], valuetype.room)
					else if (setvar == "text")
						newvalue = cyop_get_value(instancedata.variables[$ setvar], valuetype.text)
					else
						newvalue = cyop_get_value(instancedata.variables[$ setvar])
					
					if ((is_string(newvalue) || newvalue == spr_null) && spritevalue)
						warn("Sprite missing: ", newvalue == spr_null ? spritename : newvalue)
					variable_instance_set(instance, setvar, newvalue)
				}
			}
			
			if (!variable_instance_exists(instance, "escape"))
				instance.escape = false
			
			if (instance.flipX)
			{
				var hDiff = sprite_get_width(instance.sprite_index) - (sprite_get_xoffset(instance.sprite_index) * 2)
				instance.x += hDiff * instance.image_xscale
				instance.image_xscale *= -1
				if (variable_instance_exists(instance, "solid_inst"))
				{
					instance.solid_inst.x += hDiff * instance.solid_inst.image_xscale
					instance.solid_inst.image_xscale *= -1
				}
			}
			if (instance.flipY)
			{
				var vDiff = sprite_get_height(instance.sprite_index) - (sprite_get_yoffset(instance.sprite_index) * 2)
				instance.y += vDiff * instance.image_yscale
				instance.image_yscale *= -1
			}
		}
	}
}

// Set up tile layers
var tileData = roomdata.tile_data
var tileLayers = variable_struct_get_names(tileData)
var tileLayerLength = array_length(tileLayers)
for (i = 0; i < tileLayerLength; i++)
	cyop_init_tilelayer(tileLayers[i], tileData)

// Set up background layers
var bgLayers = variable_struct_get_names(roomdata.backgrounds)
var bgLayerLength = array_length(bgLayers)
for (i = 0; i < bgLayerLength; i++)
	cyop_init_bglayer(real(bgLayers[i]), variable_struct_get(roomdata.backgrounds, bgLayers[i]))