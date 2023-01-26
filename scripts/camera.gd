class_name Camera extends Camera2D

const FRAME_BASIS := 60.0

@export var transition_smoothing_curve: Curve
@export var transition_smoothing_time := 2.0
@onready var transition_smoothing_timer := transition_smoothing_time

@onready var player := Globals.player

func _process(delta: float) -> void:
	var target := player.position
	
	position.x = target.x
	position.y = target.y
	
	var was_finsihed_transitioning := transition_smoothing_timer > transition_smoothing_time
	transition_smoothing_timer += delta
	var is_finsihed_transitioning := transition_smoothing_timer > transition_smoothing_time
	if not was_finsihed_transitioning and is_finsihed_transitioning:
		position_smoothing_enabled = false
	
	var transition_smoothing_ratio := transition_smoothing_timer / transition_smoothing_time
	position_smoothing_speed = transition_smoothing_curve.sample_baked(transition_smoothing_ratio)

func _on_main_room_changed() -> void:
	transition_smoothing_timer = 0.0
	position_smoothing_speed = transition_smoothing_curve.sample_baked(0.0)
	position_smoothing_enabled = true
	
	position = player.position
	
	var bounds := Globals.main.bounds
	limit_left = bounds.position.x
	limit_top = bounds.position.y
	limit_right = bounds.end.x
	limit_bottom = bounds.end.y
