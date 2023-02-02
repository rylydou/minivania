extends Node

var entity_database := {
	'player_start': null,
	'spike': load('res://entities/spike.tscn'),
	'checkpoint': load('res://entities/checkpoint.tscn'),
	'upgrade_item': load('res://entities/upgrade_item.tscn'),
}

func run(level: Node2D) -> void:
	var level_entities:Node2D = level.get_node('entities')
	var entities: Array = level_entities.get_meta('LDtk_entity_instances')
	
	for entity in entities:
		var identifier:String = entity.identifier
		if not entity_database.has(identifier):
			print('no entity defined for %s' % identifier)
			continue
		
		var entity_scene:PackedScene = entity_database[identifier]
		if not is_instance_valid(entity_scene):
			continue
		
		var entity_node:Node2D = entity_scene.instantiate()
		entity_node.position = entity.px
		if entity_node.has_method('init'):
			entity_node.call('init', entity)
		
		level_entities.add_child(entity_node)
