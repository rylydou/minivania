extends Area2D
@export var projectiles_scene:PackedScene
@export var shoot_time:float
@export var projectile_speed:float
@export var direction:float
@export var shoot_delay:float
var til_shoot:float

# Called when the node enters the scene tree for the first time.
func init(dict: Dictionary) -> void:
	var fields: Dictionary = dict.fields
	shoot_time = fields.shoot_time
	projectile_speed = fields.projectile_speed
	direction = fields.direction
	shoot_delay= fields.shoot_delay
	til_shoot = shoot_delay/60
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta:float):
	til_shoot-=delta
	if til_shoot < 0:
		til_shoot  = shoot_time / 60
		shoot()

func shoot() -> void:
	var projectile = projectiles_scene.instantiate() as Node2D
	get_parent().add_child(projectile)
	projectile.position = position
	projectile.direction = direction
	projectile.speed = projectile_speed
