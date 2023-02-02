@tool
extends Node

var Util := preload('res://addons/amano-ldtk-importer/util/util.gd')

var layers: Dictionary = {}
func post_import(world: Node2D) -> Node2D:
	for level in world.get_children():
		world.remove_child(level)
		
		var level_data: Dictionary = level.get_meta("LDtk_raw_data")
		var level_world_depth: int = level_data.worldDepth
		
		var layer: CanvasGroup = layers.get(level_world_depth)
		if not is_instance_valid(layer):
			layer = CanvasGroup.new()
			layer.name = 'layer%s' % level_world_depth
			layer.z_index = level_world_depth
			layers[level_world_depth] = layer
		
		layer.add_child(level)
	
	for key in layers:
		var layer: CanvasGroup = layers[key]
		world.add_child(layer)
		layer.owner = world
		Util.recursive_set_owner(layer, world, null)
		
	return world
