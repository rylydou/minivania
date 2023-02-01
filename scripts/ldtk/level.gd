@tool
extends Node

var scripts = [
	preload('res://scripts/ldtk/level_add-areas.gd'),
]

func post_import(level: Node2D) -> Node2D:
	for script in scripts:
		var instance = script.new()
		level = instance.post_import(level)
	
	return level
