extends RigidBody3D

var health = 3
var speed = 3.0
@onready var bat_model: Node3D = %bat_model
@onready var timer = %Timer

# @onready var player = get_node("/root/Game/Player")
# řádek nahoře je tu normálně, řádky začánající na (var player) a (func ready) tu jsou místo toho.

var player: Node3D

func _ready() -> void:
	# Najde prvního uzla ve skupině "player" bez ohledu na strukturu scény
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI	

func take_damage():
	if health ==0:
		return
	bat_model.hurt()
	health -= 1
	if health == 0:
		set_physics_process(false)
		gravity_scale = 1.0
		var direction = -1.0 * global_position.direction_to(player.global_position)
		var random_upward_force = Vector3.UP * randf_range (1.0,5.0)
		apply_central_impulse(direction * 10.0 + random_upward_force)
		timer.start()

func _on_timer_timeout() -> void:
	queue_free()
