@tool
extends Node

var scripts = [
	preload('res://scripts/ldtk/tileset_add-collision.gd'),
]

func post_import(tileset: TileSet) -> TileSet:
	for script in scripts:
		var instance = script.new()
		tileset = instance.post_import(tileset)
	
	return tileset
