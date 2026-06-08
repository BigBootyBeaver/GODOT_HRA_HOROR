extends Node3D

@export var mob_to_spawn: PackedScene = null
@export var max_mobs_alive: int = 500       # Maximální počet živých netopýrů z tohoto spawneru
@export var spawn_distance: float = 25.0   # Spawnuje se, jen když je hráč blíž než 25m
@export var mobs_per_wave: int = 1         # Kolik netopýrů se má spawnout při jednom tiku (např. 1 nebo 3)

@onready var marker_3d: Marker3D = %Marker3D
@onready var timer: Timer = %Timer

var current_mobs_alive: int = 0            # Aktuální počet živých netopýrů
var player: Node3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_timer_timeout() -> void:
	# Kontrola 1: Existuje hráč?
	if not player: return
	
	# Kontrola 2: Je hráč dostatečně blízko?
	var distance = global_position.distance_to(player.global_position)
	if distance > spawn_distance:
		return 
		
	# Smyčka pro spawnování vlny (mobs_per_wave)
	for i in range(mobs_per_wave):
		
		# Kontrola 3 UVNITŘ SMYČKY: Pokud během spawnování dosáhneme limitu, zastavíme to
		if current_mobs_alive >= max_mobs_alive:
			break # Ukončí smyčku předčasně

		# Vytvoření instance (Všechny tyto řádky MUSÍ být odsazené v cyklu!)
		var new_mob = mob_to_spawn.instantiate()
		
		# Přidání do hlavní scény
		get_tree().current_scene.add_child(new_mob)
		
		# Nastavení pozice na Marker3D
		new_mob.global_position = marker_3d.global_position
		
		# Přičtení do počítadla
		current_mobs_alive += 1
		print("Spawnul se mob. Aktuálně živých: ", current_mobs_alive)
		
		# Propojení signálu pro odečtení po smrti
		new_mob.tree_exited.connect(_on_mob_destroyed)

# Tato funkce se zavolá sama, jakmile netopýr zavolá queue_free()
func _on_mob_destroyed() -> void:
	current_mobs_alive -= 1
	print("Mob zemřel. Zbylo živých: ", current_mobs_alive)
