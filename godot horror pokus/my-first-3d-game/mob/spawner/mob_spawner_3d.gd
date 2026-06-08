extends Node3D

@export var mob_to_spawn: PackedScene = null
@export var max_mobs_alive: int = 10       # Maximální počet živých netopýrů z tohoto spawneru
@export var spawn_distance: float = 25.0   # Spawnuje se, jen když je hráč blíž než 25m

@onready var marker_3d: Marker3D = %Marker3D
@onready var timer: Timer = %Timer

var current_mobs_alive: int = 0            # Aktuální počet živých netopýrů
var player: Node3D

func _ready() -> void:
	# Najde hráče ve skupině "player" (stejně jako v kódu netopýra)
	player = get_tree().get_first_node_in_group("player")

func _on_timer_timeout() -> void:
	# Kontrola 1: Existuje hráč? Pokud ne, nespawnuj nic
	if not player: return
	
	# Kontrola 2: Je hráč dostatečně blízko? (Bezpečnostní polštář)
	var distance = global_position.distance_to(player.global_position)
	if distance > spawn_distance:
		return # Hráč je moc daleko, přeskočíme tento tik časovače
		
	# Kontrola 3: Je už dosažen limit pro tento spawner?
	if current_mobs_alive >= max_mobs_alive:
		return # Limit naplněn, nic nového nespawnujeme

	# Všechny podmínky jsou v pořádku -> vytvoříme netopýra
	var new_mob = mob_to_spawn.instantiate()
	
	# DŮLEŽITÉ: Přidáme ho do aktuální scény, ne jako potomka spawneru (add_child(new_mob)).
	# Kdyby byl potomkem spawneru, tak by se zmrazený netopýr mohl hýbat společně se spawnerem.
	get_tree().current_scene.add_child(new_mob)
	
	print("spawnul se mob")
	new_mob.global_position = marker_3d.global_position
	
	# Zvýšíme počítadlo živých netopýrů
	current_mobs_alive += 1
	
	# PROPOJENÍ: Sledujeme, kdy netopýr zemře (opustí herní scénu)
	new_mob.tree_exited.connect(_on_mob_destroyed)

# Tato funkce se zavolá sama, jakmile netopýr zavolá queue_free()
func _on_mob_destroyed() -> void:
	current_mobs_alive -= 1
