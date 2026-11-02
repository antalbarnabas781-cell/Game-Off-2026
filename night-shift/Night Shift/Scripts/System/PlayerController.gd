
extends Node3D

@export var mouse_sensitivity: float = 0.002
@export var max_look_angle: float = 55.0

@onready var look_pivot: Node3D = $LookPivot
@onready var player_camera: Camera3D = $LookPivot/Camera3D

var mouse_captured: bool = true


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	# Egér mozgatása
	if event is InputEventMouseMotion and mouse_captured:
		# Vízszintes forgás
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Függőleges nézés
		look_pivot.rotate_x(
			-event.relative.y * mouse_sensitivity
		)

		# Függőleges korlátozás
		look_pivot.rotation.x = clamp(
			look_pivot.rotation.x,
			deg_to_rad(-max_look_angle),
			deg_to_rad(max_look_angle)
		)

	# ESC - egérkurzor felszabadítása
	if event.is_action_pressed("ui_cancel"):
		mouse_captured = not mouse_captured

		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Bal egérgomb - interakció
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not mouse_captured:
				mouse_captured = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				interact_with_object()


func interact_with_object():
	var space_state = get_world_3d().direct_space_state

	var origin = player_camera.global_position
	var direction = -player_camera.global_transform.basis.z

	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * 3.0
	)

	var result = space_state.intersect_ray(query)

	if result:
		var object = result.collider

		if object.has_method("interact"):
			object.interact()
