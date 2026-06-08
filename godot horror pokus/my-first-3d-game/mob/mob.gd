extends RigidBody3D

var health = 3
var speed = 3.0
@onready var bat_model: Node3D = %bat_model
@onready var timer = %Timer

# Nové proměnné pro správu vzdálenosti
@export var max_distance: float = 30  # Vzdálenost, kdy se netopýr zmrazí
var player: Node3D
var is_frozen_by_distance: bool = false # Pojistka, abychom nemrazili už mrtvého netopýra

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

# Použijeme _process pro neustálou kontrolu vzdálenosti, i když je fyzika vypnutá
func _process(delta: float) -> void:
	# Pokud netopýr ještě žije, kontrolujeme vzdálenost k hráči
	if health > 0 and player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance > max_distance and not is_frozen_by_distance:
			# HRÁČ JE DALEKO: Zmrazíme netopýra
			is_frozen_by_distance = true
			freeze = true # Vypne veškerou fyziku Godotu pro toto těleso
			linear_velocity = Vector3.ZERO # Zastaví pohyb
			set_physics_process(false) # Vypne otáčení a kód níže
			
		elif distance <= max_distance and is_frozen_by_distance:
			# HRÁČ SE VRÁTIL: Rozmrazíme netopýra
			is_frozen_by_distance = false
			freeze = false
			set_physics_process(true)

func _physics_process(delta):
	# Pro jistotu ověříme, že hráč existuje (např. pokud by zemřel)
	if not player: return 
	
	var direction = global_position.direction_to(player.global_position)
	# direction.y = 0.0
	linear_velocity = direction * speed
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI	

func take_damage():
	if health == 0:
		return
	bat_model.hurt()
	health -= 1
	if health == 0:
		set_physics_process(false)
		freeze = false # Ujistíme se, že mrtvola padá k zemi
		gravity_scale = 1.0
		var direction = -1.0 * global_position.direction_to(player.global_position)
		var random_upward_force = Vector3.UP * randf_range(1.0, 5.0)
		apply_central_impulse(direction * 10.0 + random_upward_force)
		timer.start()

func _on_timer_timeout() -> void:
	queue_free()
