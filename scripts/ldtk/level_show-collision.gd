@tool
extends Node

func post_import(level: Node2D) -> Node2D:
	for child in level.get_children():
		if child is TileMap:
			child = child as TileMap
			child.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_SHOW
	return level
