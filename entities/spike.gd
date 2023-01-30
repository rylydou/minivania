class_name Spike extends Area2D

const TPS := 60.0

@export var wait_time := 0.5
@export var speed := 8.0
@export var points: Array[Vector2] = []

func init(dict: Dictionary) -> void:
	var fields: Dictionary = dict.fields
	
	wait_time = fields.wait_ticks / TPS
	
	speed = fields.speed
	
	points = fields.points
	points = points.map(func(point): return point * 8 + Vector2(4, 4))
	points.push_front(position)
	
	next_point()

var index := 0
var wait_timer := 0.0
var target_point: Vector2
func _physics_process(delta: float) -> void:
	#return
	if position == target_point:
		wait_timer += delta
		if wait_timer <= wait_time:
			return
		wait_timer = 0.0
		
		next_point()
	
	position = position.move_toward(target_point, speed * delta)

func next_point() -> void:
	index += 1
	if index >= points.size():
		index = 0
	
	target_point = points[index]
