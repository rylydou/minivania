class_name Main extends Node

signal level_changed()

var entity_spawner := preload('res://scripts/entity_spawner.gd').new()

@onready var player: Player = Globals.player

var current_level: Node
var previous_level: Node

var bounds: Rect2

func _enter_tree() -> void:
	Globals.main = self
	get_window().grab_focus()

func _ready() -> void:
	var entity_instances: Array[Dictionary] = $Map/start/entities.get_meta('LDtk_entity_instances')
	
	for entity_instance in entity_instances:
		if entity_instance.identifier != 'player_start': continue
		
		print('found player start at %s' % entity_instance.px)
		player.position = entity_instance.px
		player.set_respawn_point()
		player.position.y -= 8
		break

func enter_room(level: Node2D):
	print('cleaning previous level')
	if level:
		var level_entities:Node2D = level.get_node('entities')
		for entity in level_entities.get_children():
			level_entities.remove_child(entity)
			entity.queue_free()
	
	print('going to level %s' % level.name)
	
	var level_data: Dictionary = level.get_meta("LDtk_raw_data")
	
	var x: float = level_data.worldX
	var y: float = level_data.worldY
	var width: float = level_data.pxWid
	var height: float = level_data.pxHei
	
	bounds = Rect2(x, y, width, height)
	current_level = level
	
	$Camera.position = bounds.get_center()
	previous_level = current_level
	
	level_changed.emit()
	
	entity_spawner.call_deferred('run', level)

func _on_player_entered_level(level: Node2D) -> void:
	enter_room(level)
