class_name Player extends CharacterBody2D

signal entered_level(level: Node2D);

const TPS = 60.0

@export_group('Platformer State')
@export var walk_speed := 36.0

@export_subgroup('Jump')
@export var jump_ticks := 35
@onready var jump_time := jump_ticks / TPS
@export var jump_height := 18.0
@export var max_fall_speed_ratio := 1.5
var is_jumping := false

@onready var normal_gravity := calculate_gravity_for_jump(jump_height, jump_time)

@export_subgroup('Assits')
@export var coyote_time_ticks := 6
var coyote_timer := -1.0
@export var jump_buffer_ticks := 6
var jump_buffer_timer := -1.0
@export var max_bonknuge_distance := 4.0

@export_subgroup('Double Jump')
@export var double_jump_height := 18.0
var can_double_jump := false
var is_double_jumping := false

@export_subgroup('Dash')
@export var dash_distance := 32.0
@export var dash_ticks := 12.0
@onready var dash_time := dash_ticks / TPS
var dash_timer := 0.0
var can_dash := false

@export_group('Climb State')
@export var climb_speed_vertical := 24.0
@export var climb_speed_horizontal := 16.0
@export var climb_coyote_time_ticks := 10
var is_clibing := false

@export_group('Swim State')
@export var swim_speed := 24.0
@export var swim_surface_jump_height := 24.0
@export var swim_gravity_reduce := 0.5

@export_group('Dead State')
@export var death_wait_ticks := 10
@export var death_glide_speed_curve: Curve
@export var death_glide_speed_time := 1.0
var time_dead := 0.0

var is_swiming := false
var is_dead := false

var gravity: float

@onready var art_node: Node2D = $Flip/Art

func _enter_tree() -> void:
	Globals.player = self

func _process(delta: float) -> void:
	
	process_inputs()
	
	if Input.is_key_pressed(KEY_K) and not is_dead:
		die()
	
	var anim := get_animation()
	$Flip/Art/AnimationPlayer.play(anim)
	
	if is_dead: return
	
	if input_move.x != 0:
		facing_direction = sign(input_move.x)
		$Flip.scale.x = facing_direction
	
	if Input.is_action_just_pressed('debug_teleport'):
		position = get_global_mouse_position()
		speed_vertical = 0

func get_animation() -> String:
	$Flip/Art/AnimationPlayer.speed_scale = 1.0
	if is_dead:
		return 'hurt'
	
	if is_clibing:
		if input_move.y == 0.0:
			$Flip/Art/AnimationPlayer.speed_scale = 0.0
		return 'climb'
	
	if dash_timer > 0.0:
		return 'dash'
	
	if is_on_floor():
		if speed_move != 0.0:
			return 'walk'
		return 'idle'
	# is airborne:
	
	if is_double_jumping:
		return 'double_jump'
	if is_jumping:
		return 'jump'
	return 'fall'

func reset_movement() -> void:
	is_dead = false
	time_dead = 0.0
	
	speed_move = 0.0
	speed_extra = 0.0
	speed_vertical = 0.0
	
	is_jumping = false
	
	can_double_jump = true
	is_double_jumping = false
	
	can_dash = true
	dash_timer = 0.0
	
	is_clibing = false
	

var input_move := Vector2.ZERO
var input_jump_press := false
var input_action_press := false
func process_inputs() -> void:
	input_move.x = Input.get_axis('move_left', 'move_right')
	input_move.y = Input.get_axis('move_up', 'move_down')
	
	if Input.is_action_just_pressed('jump'):
		input_jump_press = true
	
	if Input.is_action_just_pressed('action'):
		input_action_press = true

var speed_move := 0.0
var speed_extra := 0.0
var speed_vertical := 0.0
var facing_direction := 1.0
func _physics_process(delta: float) -> void:
	if is_dead:
		time_dead += delta
		
		var speed := death_glide_speed_curve.sample_baked(time_dead / death_glide_speed_time)
		position = position.move_toward(respawn_point, speed * delta)
		
		if position == respawn_point:
			reset_movement()
		else:
			return
	
	gravity = normal_gravity
	
	if is_swiming:
		if $SwimArea.get_overlapping_bodies().size() == 0:
			is_swiming = false
			gravity = normal_gravity
			speed_vertical = -calculate_jump_velocity(swim_surface_jump_height)
		else: 
			gravity *= swim_gravity_reduce
			coyote_timer = coyote_time_ticks / TPS
			can_double_jump = true
			can_dash = true
	elif $SwimArea.get_overlapping_bodies().size() > 0:
		is_swiming = true
		is_jumping = false
		is_double_jumping = false
	
	if is_clibing:
		process_state_climb(delta)
	elif dash_timer > 0.0:
		process_state_dash(delta)
	else:
		process_state_platformer(delta)
	
	input_jump_press = false
	input_action_press = false

func process_state_climb(delta: float) -> void:
	if $ClimbArea.get_overlapping_bodies().size() == 0 or is_on_floor():
		is_clibing = false
		coyote_timer = climb_coyote_time_ticks / TPS
	
	speed_vertical = input_move.y * climb_speed_vertical
	speed_move = input_move.x * climb_speed_horizontal
	
	if input_jump_press:
		speed_vertical = -calculate_jump_velocity(jump_height)
		is_jumping = true
		is_clibing = false
	
	move()

func process_state_dash(delta: float) -> void:
	dash_timer -= delta
	move_and_slide()
	process_doublejump(delta)
	if input_jump_press or is_on_wall():
		dash_timer = 0.0

func process_state_platformer(delta: float) -> void:
	if is_on_floor():
		can_dash = true
		can_double_jump = true
		is_jumping = false
		is_double_jumping = false

	if $ClimbArea.get_overlapping_bodies():
		if input_move.y != 0.0 and not (is_on_floor() and input_move.y > 0.0):
			is_clibing = true
			is_jumping = false
			is_double_jumping = false
			can_dash = true
			can_double_jump = true
	
	process_movement(delta)
	process_gravity(delta)
	process_jump(delta)
	process_doublejump(delta)
	
	move()
	
	process_dash(delta)

func process_movement(delta: float) -> void:
	var speed := swim_speed if is_swiming else walk_speed
	
	speed_move = input_move.x * speed
	
	var hit_wall_on_left := is_on_wall() and test_move(transform, Vector2.LEFT)
	var hit_wall_on_right := is_on_wall() and test_move(transform, Vector2.RIGHT)
	
	if hit_wall_on_left:
		if speed_move < 0.0:
			speed_move = 0.0
		if speed_extra < 0.0: 
			speed_extra = 0.0
	
	if hit_wall_on_right:
		if speed_move > 0.0:
			speed_move = 0.0
		if speed_extra > 0.0: 
			speed_extra = 0.0

func process_gravity(delta: float) -> void:
	if is_on_ceiling():
		if !try_bonknudge(max_bonknuge_distance * facing_direction):
			if speed_vertical < 0.0: speed_vertical = 0.0
	
	if is_on_floor():
		if speed_vertical > 0.0: 
			speed_vertical = 0.0
	else:
		speed_vertical += gravity * delta
	
	var max_fall_speed := calculate_jump_velocity(jump_height) * max_fall_speed_ratio
	if speed_vertical > max_fall_speed:
		speed_vertical = max_fall_speed

func try_bonknudge(distance: float) -> bool:
	var x := 0.0
	while x != distance:
		if !test_move(transform.translated(Vector2(x, 0)), Vector2.UP):
			position.x += x
			return true
		x = move_toward(x, distance, 1)
	return false

func process_jump(delta: float) -> void:
	if Input.is_action_pressed('debug_fly'):
		if speed_vertical > 0.0:
			speed_vertical = 0.0
		speed_vertical -= gravity * delta * 2
	
	coyote_timer -= delta
	if is_on_floor():
		coyote_timer = coyote_time_ticks / TPS
	
	jump_buffer_timer -= delta
	if input_jump_press:
		jump_buffer_timer = jump_buffer_ticks / TPS
	
	if coyote_timer > 0.0 and jump_buffer_timer > 0.0:
		is_jumping = true
		input_jump_press = false
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		
		var jump_velocity := calculate_jump_velocity(jump_height)
		speed_vertical = -jump_velocity

func process_doublejump(delta: float) -> void:
	if can_double_jump and input_jump_press:
		is_double_jumping = true
		is_jumping = false
		can_double_jump = false
		
		var jump_velocity := calculate_jump_velocity(double_jump_height)
		speed_vertical = -jump_velocity

func process_dash(delta: float) -> void:
	if can_dash and input_action_press:
		speed_move = 0.0
		speed_extra = 0.0
		speed_vertical = 0.0
		can_dash = false
		dash_timer = dash_time
		velocity.x = dash_distance / dash_time * facing_direction
		velocity.y = 0.0

func move() -> void:
	velocity.x = speed_move + speed_extra
	velocity.y = speed_vertical
	
	move_and_slide()

func calculate_gravity_for_jump(height: float, duration: float) -> float:
	return 8 * (height / pow(duration, 2))

func calculate_jump_velocity(height: float) -> float:
	return sqrt(2 * gravity * height)

var respawn_point: Vector2
func set_respawn_point() -> void:
	respawn_point = position

func die() -> void:
	if is_dead: return
	is_dead = true
	time_dead = 0.0

func _on_level_detector_area_entered(area: Area2D) -> void:
	entered_level.emit(area.get_parent())
	set_respawn_point()
	if speed_vertical < 0.0:
		speed_vertical = -calculate_jump_velocity(8 * 3.0 + 2)
	can_double_jump = true


func _on_hurtbox_area_entered(area: Area2D) -> void:
	die()
