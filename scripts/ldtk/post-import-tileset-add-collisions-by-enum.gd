@tool
extends Node

const Tile = preload("res://addons/amano-ldtk-importer/util/tile.gd")

var flag_shape_box := 'shape_box'
var flag_shape_bottom := 'shape_bottom'
var flag_shape_thin := 'shape_thin'

var flag_layer_solid := 'layer_solid'
var physics_layer_solid := 1
var flag_layer_climb := 'layer_climb'
var physics_layer_climb := 2
var flag_layer_swim := 'layer_swim'
var physics_layer_swim := 4

var flag_ext_oneway := 'ext_oneway'

const CUSTOM_DATA_LAYER_NAME := 'LDtk_tile_data'

# This script adds a square collision polygon the size of the tile
# to all the tiles that have the "Collision" enum
func post_import(tileset: TileSet) -> TileSet:
	var tileset_layer_solid_id := 0
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(tileset_layer_solid_id, physics_layer_solid)
	tileset.set_physics_layer_collision_mask(tileset_layer_solid_id, 0)
	var tileset_layer_climb_id := 1
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(tileset_layer_climb_id, physics_layer_climb)
	tileset.set_physics_layer_collision_mask(tileset_layer_climb_id, 0)
	var tileset_layer_swim_id := 2
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(tileset_layer_swim_id, physics_layer_swim)
	tileset.set_physics_layer_collision_mask(tileset_layer_swim_id, 0)
	
	var source_count := tileset.get_source_count()
	for index in range(0, source_count):
		var source_index := int(index)
		var tileset_source_id := tileset.get_source_id(source_index)
		var tileset_source := tileset.get_source(tileset_source_id)
		var tileset_data_layer_id := tileset.get_custom_data_layer_by_name(CUSTOM_DATA_LAYER_NAME)
		
		# There is no TilesetDataLayer with name "LDtk"
		if tileset_data_layer_id == -1:
			return tileset
		
		var tile_size := tileset.tile_size
		var tile_extents := Vector2(tile_size.x/2, tile_size.y/2)
		var grid_size: Vector2i = tileset_source.get_atlas_grid_size()
		
		for y in range(0, grid_size.y):
			for x in range(0, grid_size.x):
				var alternative_tile := 0
				var grid_coords := Vector2i(x,y)

				var has_tile :bool = tileset_source.get_tile_at_coords(grid_coords) != Vector2i(-1,-1)
				if not has_tile: continue
				
				var tile_id := Tile.tile_grid_coords_to_tile_id(grid_coords, grid_size.x)
				var tile_data: TileData = tileset_source.get_tile_data(grid_coords, alternative_tile)
				var tile_custom_data: Dictionary= tile_data.get_custom_data(CUSTOM_DATA_LAYER_NAME)
				if tile_custom_data != null and tile_custom_data != {}:
					var enums: Array = tile_custom_data.get('enums')
					
					var layer_id := tileset_layer_solid_id
					
					if enums.has(flag_layer_solid):
						layer_id = tileset_layer_solid_id
					elif enums.has(flag_layer_climb):
						layer_id = tileset_layer_climb_id
					elif enums.has(flag_layer_swim):
						layer_id = tileset_layer_swim_id
					else: print('no layer defined')
					
					tile_data.add_collision_polygon(layer_id)
					if enums.has(flag_shape_box):
						add_box_polygon(tile_data, tile_extents, layer_id)
					elif enums.has(flag_shape_thin):
						add_thin_polygon(tile_data, tile_extents, layer_id)
					elif enums.has(flag_shape_bottom):
						add_bottom_polygon(tile_data, tile_extents, layer_id)
					else: print('no shape defined')
					
					if enums.has(flag_ext_oneway):
						tile_data.set_collision_polygon_one_way(layer_id, 0, true)

	return tileset

func add_box_polygon(data: TileData, extents: Vector2, layer_id: int) -> void:
	data.set_collision_polygon_points(
		layer_id,
		0,
		PackedVector2Array(
			[
				Vector2(-extents.x, -extents.y),
				Vector2(-extents.x, extents.y),
				Vector2(extents.x, extents.y),
				Vector2(extents.x, -extents.y)
			]
		)
	)

func add_thin_polygon(data: TileData, extents: Vector2, layer_id: int) -> void:
	data.set_collision_polygon_points(
		layer_id,
		0,
		PackedVector2Array(
			[
				Vector2(-extents.x/2, -extents.y),
				Vector2(-extents.x/2, extents.y),
				Vector2(extents.x/2, extents.y),
				Vector2(extents.x/2, -extents.y)
			]
		)
	)

func add_bottom_polygon(data: TileData, extents: Vector2, layer_id: int) -> void:
	data.set_collision_polygon_points(
		layer_id,
		0,
		PackedVector2Array(
			[
				Vector2(-extents.x, 0),
				Vector2(-extents.x, extents.y),
				Vector2(extents.x, extents.y),
				Vector2(extents.x, 0)
			]
		)
	)
