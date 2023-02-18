extends CharacterBody2D

@export var speed:float
@export var direction:float


func _process(delta):
	if move_and_collide(Vector2(speed * cos(direction/180 * PI) * delta, -speed * sin(direction/180 * PI) * delta)):
		queue_free()
