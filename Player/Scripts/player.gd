extends CharacterBody3D 
@onready var camroot: Node3D = $Camroot

var camera_3d : Camera3D
@onready var state_machine: State_Machine = $State_Machine
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var charater_mesh: Node3D = $character_mesh


const ROTATION_SPEED = 10.0  # How fast the character rotates to face direction

const RUN_SPEED: float = 7
const WALK_SPEED : float = 2
var cur_speed 
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	state_machine.connect("state_changed",_on_state_changed)
	cur_speed = WALK_SPEED
	print(camroot.get_child(0).get_child(0))
	camera_3d = camroot.get_child(0).get_child(0).get_child(0)
func _physics_process(delta: float) -> void:
	
	handle_movement(delta)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

		
func handle_movement(delta: float):
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction
	var input_dir = Input.get_vector("left","right" , "down", "up")
	if input_dir != Vector2.ZERO:
		# Camera-based movement
		var cam_transform = camera_3d.global_transform
		
		var forward = -cam_transform.basis.z
		var right = cam_transform.basis.x

		# Flatten vectors to XZ plane
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()

		# Get movement direction in world space
		var direction = (right * input_dir.x + forward * input_dir.y).normalized()

		# Apply movement
		velocity.x = direction.x * cur_speed
		velocity.z = direction.z * cur_speed

		# Face direction
		face_direction(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0, cur_speed)
		velocity.z = move_toward(velocity.z, 0, cur_speed)

# Rotate character to face the movement direction
func face_direction(direction: Vector3, delta: float):
	if direction.length() == 0:
		return

	# Compute target Y-rotation
	var target_rotation = atan2(direction.x, direction.z)

	# Smooth rotation
	var current_rotation = charater_mesh.rotation.y
	var new_rotation = lerp_angle(current_rotation, target_rotation, ROTATION_SPEED * delta)
	charater_mesh.rotation.y = new_rotation

	
func _on_state_changed(new_state: State_Machine.State, old_state: State_Machine.State) -> void:

	match new_state:
		state_machine.State.IDLE:
			turn_state_true("is_idle")
		state_machine.State.WALKING:
			turn_state_true("is_walking")
		state_machine.State.RUNNING:
			turn_state_true("is_running")
		state_machine.State.JUMPING:
			turn_state_true("is_jumping")

func turn_state_true(given_state: String):
	'''
	This function does the same as following, if is_walking is given as given_state.

	animation_tree["parameters/conditions/is_running"] = true
	animation_tree["parameters/conditions/is_walking"] = false
	animation_tree["parameters/conditions/is_idle"] = false
	'''
	var states: Array = ["is_idle", "is_walking", "is_running", "is_jumping"]
	for state in states:
		animation_tree["parameters/conditions/" + state] = (given_state == state)
