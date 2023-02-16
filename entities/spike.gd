class_name Spike extends Area2D

const TPS := 60.0

@export var wait_time := 0.5
@export var speed := 8.0
@export var points: Array[Vector2] = []
@export var curve: Curve

func init(dict: Dictionary) -> void:
	var fields: Dictionary = dict.fields
	
	wait_time = fields.wait_ticks / TPS
	
	speed = fields.speed
	
	points.clear()
	for point in fields.points:
		points.push_back(Vector2(point) * 8 + Vector2(4, 4)) 
	points.push_front(position)
	
	next_point()

var index := 0
var wait_timer := 0.0
var start_point: Vector2
var target_point: Vector2
var distance := 0.0
var progress := 0.0
func _physics_process(delta: float) -> void:
	#return
	if position == target_point:
		wait_timer += delta
		if wait_timer <= wait_time:
			return
		wait_timer = 0.0
		
		next_point()
	
	progress += speed * delta
	position = start_point.lerp(target_point, curve.sample_baked(progress / distance))
	# position = position.move_toward(target_point, speed * delta)

func next_point() -> void:
	index += 1
	if index >= points.size():
		index = 0
	
	start_point = position
	target_point = points[index]
	distance = start_point.distance_to(target_point)
	progress = 0.0
