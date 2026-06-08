extends CharacterBody3D
var zivoty: int = 3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.4
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.15
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -80.0, 80.0
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	const SPEED = 5.5
	var input_dirrection_2D = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	
	var input_dirrection_3D = Vector3(
		input_dirrection_2D.x, 0.0, input_dirrection_2D.y
	)
	
	var dirrection = transform.basis * input_dirrection_3D 
	
	velocity.x = dirrection.x * SPEED
	velocity.z = dirrection.z * SPEED
	
	velocity.y -= 20.0 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0
	move_and_slide()
	
	
	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()
	
func shoot_bullet():
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
		
	new_bullet.global_transform = %Marker3D.global_transform
	
	%Timer.start()
	





func _on_detekce_narazu_body_entered(body: Node3D) -> void:
	 # Ověříme, zda to, co do nás vrazilo, je ze skupiny "nepritel"
	if body.is_in_group("nepritel"):
		uber_zivot()



func uber_zivot() -> void:
	zivoty -= 1
	print("Hráč dostal zásah! Zbývající životy: ", zivoty)
	

	
	if zivoty <= 0:
		print("Konec hry!")
		restituuj_hru()

func restituuj_hru() -> void:
	# Restartuje aktuální scénu (úroveň) odznova
	get_tree().reload_current_scene()
