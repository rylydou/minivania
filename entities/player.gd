class_name Player extends CharacterBody2D

signal entered_room(room: Node2D);

const FRAME_BASIS = 60.0

@export_group('Movement')
@export var move_max_speed := 12.0

@export var move_acc_curve: Curve
@export var move_acc_frames := 8
@onready var move_acc_time := move_acc_frames / FRAME_BASIS

@export var move_dec_curve: Curve
@export var move_dec_frames := 6
@onready var move_dec_time := move_dec_frames / FRAME_BASIS

@export_group('Jumping')
@export var jump_frames := 60
@onready var jump_time := jump_frames / FRAME_BASIS
@export var jump_height_max := 18.0
@export var max_fall_speed_ratio := 2.0

@onready var gravity := calculate_gravity_for_jump(jump_height_max, jump_time)
@onready var max_fall_speed := calculate_jump_velocity(jump_height_max) * max_fall_speed_ratio

@export_group('Assits')
@export var coyote_time_frames := 6
var coyote_timer := -1.0
@export var jump_buffer_frames := 6
var jump_buffer_timer := -1.0
@export var max_bonknuge_distance := 4.0

func _enter_tree() -> void:
	Globals.player = self

var input_move := Vector2.ZERO
var input_jump := false
var input_jump_press := false
func _process(delta: float) -> void:
	process_inputs()
	
	if input_move.x != 0:
		facing_direction = sign(input_move.x)
		$Flip.scale.x = facing_direction
	
	if Input.is_action_just_pressed('debug_teleport'):
		position = get_global_mouse_position()
		speed_vertical = 0

func process_inputs() -> void:
	input_move.x = Input.get_axis('move_left', 'move_right')
	input_move.y = Input.get_axis('move_down', 'move_up')
	
	input_jump = Input.is_action_pressed('jump')
	
	if Input.is_action_just_pressed('jump'):
		input_jump_press = true

var speed_move = 0.0
var speed_extra = 0.0
var speed_vertical = 0.0
var facing_direction = 1.0
func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_gravity(delta)
	process_jump(delta)
	
	move()

func process_movement(delta: float) -> void:
	speed_move = input_move.x * move_max_speed
	
	var hit_wall_on_left := test_move(transform, Vector2.LEFT)
	var hit_wall_on_right := test_move(transform, Vector2.RIGHT)
	
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
			speed_vertical = gravity * delta
	else:
		speed_vertical += gravity * delta
	
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

var can_control_fall_speed := false
func process_jump(delta: float) -> void:
	if Input.is_action_pressed('debug_fly'):
		if speed_vertical > 0.0:
			speed_vertical = 0.0
		speed_vertical -= gravity * delta * 2
	
	coyote_timer -= delta
	if is_on_floor():
		coyote_timer = coyote_time_frames / FRAME_BASIS
	
	jump_buffer_timer -= delta
	if input_jump_press:
		jump_buffer_timer = jump_buffer_frames / FRAME_BASIS
		input_jump_press = false
	
	if coyote_timer > 0.0 and jump_buffer_timer > 0.0:
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		
		var jump_velocity := calculate_jump_velocity(jump_height_max)
		speed_vertical = -jump_velocity
		
		can_control_fall_speed = true

func move() -> void:
	velocity.x = speed_move + speed_extra
	velocity.y = speed_vertical
	up_direction = Vector2.UP
	
	move_and_slide()

func calculate_gravity_for_jump(height: float, duration: float) -> float:
	return 8 * (height / pow(duration, 2))

func calculate_jump_velocity(height: float) -> float:
	return sqrt(2 * gravity * height)

func _on_room_detector_area_entered(area: Area2D) -> void:
	entered_room.emit(area.get_parent())
