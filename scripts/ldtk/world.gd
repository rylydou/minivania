@tool
extends Node

var scripts = [
	preload('res://scripts/ldtk/world_separate_layers.gd'),
]

func post_import(world: Node2D) -> Node2D:
	for script in scripts:
		var instance = script.new()
		world = instance.post_import(world)
	
	return world
