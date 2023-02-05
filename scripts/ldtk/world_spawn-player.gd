@tool
extends Node

func post_import(world: Node2D) -> Node2D:
	for level in world.get_children():
		var found_position := find_player(level)
		if found_position == Vector2i.ZERO: continue
		
		world = spawn_player(world, found_position)
		return world
	
	world = spawn_player(world, Vector2.ZERO)
	return world

func spawn_player(world: Node2D, position: Vector2i) -> Node2D:
	world.set_meta('player_position', position)
	return world

func find_player(level: Node2D) -> Vector2i:
	var level_data: Dictionary = level.get_meta('LDtk_raw_data')
	var level_entities: Node2D = level.get_node('entities')
	var entity_instances: Array = level_entities.get_meta('LDtk_entity_instances')
	
	for entity_instance in entity_instances:
		if entity_instance.identifier != 'player_start': continue
		
		return Vector2i(level_data.worldX, level_data.worldY) + entity_instance.px
	
	return Vector2i.ZERO
