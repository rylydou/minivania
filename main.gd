class_name Main extends Node

var current_room: Node
var prev_room: Node

@onready var player: Player = $Player

var bounds: Rect2

func enter_room(room: Node2D):
	print('going to room %s' % room.name)
	
	var level_data :Dictionary = room.get_meta("LDtk_raw_data")
	
	var x:float = level_data.worldX
	var y:float = level_data.worldY
	var width:float = level_data.pxWid
	var height:float = level_data.pxHei
	
	bounds = Rect2(x, y, width, height)
	current_room = room
	
	$Camera.position = bounds.get_center()
	prev_room = current_room

func _on_player_entered_room(room: Node2D) -> void:
	enter_room(room)
