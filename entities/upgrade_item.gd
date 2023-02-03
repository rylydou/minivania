extends Area2D

@export var upgrade_type: String

func init(dict: Dictionary) -> void:
	var fields: Dictionary = dict.fields
	
	upgrade_type = fields.upgrade_type
	
	$Label.text = upgrade_type

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if not player: return
	
	Upgrades.set_upgrade(upgrade_type, true)
