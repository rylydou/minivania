extends Area2D

@export var height := 32.0

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if not player: return
	
	player.speed_vertical = -player.calculate_jump_velocity(height)

func init(dict: Dictionary) -> void:
	var fields: Dictionary = dict.fields
	height = fields.height * 8.0
