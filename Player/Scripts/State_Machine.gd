class_name State_Machine extends Node

# Define possible states
enum State {
	IDLE,
	WALKING,
	RUNNING,
	JUMPING
}

# Current state
var current_state:  = State.IDLE
var previous_state: = State.IDLE
var player: CharacterBody3D
# State change signal for other nodes to listen to
signal state_changed(new_state: State, old_state: State)

func _ready() -> void:
	player = get_parent()
	# Initialize state machine
	enter_state(current_state)

func _process(delta: float) -> void:
	# Update current state
	update_state(delta)

# Change to a new state
func change_state(new_state: State) -> void:
	if new_state != current_state:
		exit_state(current_state)
		previous_state = current_state
		current_state = new_state
		enter_state(current_state)
		state_changed.emit(current_state, previous_state)

# Called when entering a state
func enter_state(state: State) -> void:
	match state:
		State.IDLE:
			print("Entering IDLE state")
		State.WALKING:
			print("Entering MOVING state")
		State.RUNNING:
			print("Entering RUNNING state")
		State.JUMPING:
			print("Entering JUMPING state")

# Called when exiting a state
func exit_state(state: State) -> void:
	match state:
		State.IDLE:
			print("Exiting IDLE state")
		State.WALKING:
			print("Exiting MOVING state")
		State.RUNNING:
			print("EXITING RUNNING state")
		State.JUMPING:
			print("Exiting JUMPING state")

# Update current state logic
func update_state(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle_state(delta)
		State.WALKING:
			handle_moving_state(delta)
		State.RUNNING:
			handle_running_state(delta)
		State.JUMPING:
			handle_jump_state(delta)

func handle_jump_state(delta: float) -> void:
	if player.is_on_floor():
		if player.velocity == Vector3.ZERO:
			change_state(State.IDLE)
		else:
			if Input.is_action_pressed("run"):
				change_state(State.RUNNING)
			else:
				change_state(State.WALKING)
	else:
		print('in air')
# State-specific update functions
func handle_idle_state(delta: float) -> void:
	if player.velocity!=Vector3.ZERO:
		change_state(State.WALKING)
	
	if !player.is_on_floor():
		change_state(State.JUMPING)

func handle_moving_state(delta: float) -> void:
	player.cur_speed = player.WALK_SPEED

	if player.velocity == Vector3.ZERO:
		change_state(State.IDLE)
	elif Input.is_action_just_pressed("run"):
		change_state(State.RUNNING)

	if !player.is_on_floor():
		change_state(State.JUMPING)
func handle_running_state(delta: float):
	player.cur_speed = player.RUN_SPEED
	if !Input.is_action_pressed("run"):
		change_state(State.WALKING)
	if !player.is_on_floor():
		change_state(State.JUMPING)

# Utility functions
func get_current_state() -> State:
	return current_state

func get_previous_state() -> State:
	return previous_state

func is_state(state: State) -> bool:
	return current_state == state
