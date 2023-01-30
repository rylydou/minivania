@tool
extends Node

var level_area_padding := Vector2i(-1, -1)
var level_area_collision_layer := 8
var level_area_opacity := 0.25

func post_import(level: Node2D) -> Node2D:
	var level_fields :Dictionary = level.get_meta("LDtk_level_fields")
	var level_data :Dictionary = level.get_meta("LDtk_raw_data")
	var source_file :String = level.get_meta("LDtk_source_file")
	var level_area := get_level_area(level_fields, level_data, {
		"level_area_padding": level_area_padding,
		"level_area_collision_layer": level_area_collision_layer,
		"level_area_opacity": level_area_opacity
	})
	level.add_child(level_area)
	return level

static func get_level_area(
	level_fields: Dictionary,
	level_data: Dictionary,
	options: Dictionary
) -> Area2D:
	var level_area = Area2D.new()
	var level_size = Vector2i(level_data.pxWid, level_data.pxHei)
	var level_extents = (level_size / 2) + options.level_area_padding
	var area_collision_layer = options.level_area_collision_layer

	level_area.name = "Area"

	level_area.position.x = level_extents.x
	level_area.position.y = level_extents.y
	level_area.set_collision_layer_value(area_collision_layer, true)
	level_area.collision_mask = 0
	level_area.show_behind_parent = true

	var level_area_shape = CollisionShape2D.new()
	level_area_shape.name = "Shape"
	level_area_shape.shape = RectangleShape2D.new()
	level_area_shape.shape.extents = level_extents
	
	if level_fields.has("Color"):
		level_area_shape.visible = true
		level_area_shape.debug_color = Color(level_fields.Color)
	else:
		var rng = RandomNumberGenerator.new()
		rng.seed = hash(level_data.uid)
		level_area_shape.debug_color.r = rng.randf()
		level_area_shape.debug_color.g = rng.randf()
		level_area_shape.debug_color.b = rng.randf()
	
	level_area_shape.debug_color.a = options.level_area_opacity

	level_area.add_child(level_area_shape)

	return level_area
