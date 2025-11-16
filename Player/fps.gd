extends CharacterBody3D

const SPEED = 5.0
const JUMP = 4.5

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 1.0) var RStick_sensitivity := 5.5
var camera_input_direction := Vector2.ZERO

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_controller: SpringArm3D = %"CameraController"


func _physics_process(delta: float) -> void:

	#Add Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP

	#Movement
	var inputDir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (camera_pivot.transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	##Camera

	handle_Camera(delta)


	move_and_slide()

func handle_Camera(delta: float) -> void:
	# Controller support
	var axis_vector = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if axis_vector.length() >= 0.2:
		camera_input_direction = axis_vector * RStick_sensitivity

	#main
	camera_pivot.rotation.x -= camera_input_direction.y * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI /3.0, PI/6.0)
	camera_pivot.rotation.y -= camera_input_direction.x * delta

	camera_input_direction = Vector2.ZERO

# mouse camera stuff
func _unhandled_input(event: InputEvent) -> void:
	var iscamera_motion := ( event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		)
	if iscamera_motion:
		camera_input_direction = event.screen_relative * mouse_sensitivity
