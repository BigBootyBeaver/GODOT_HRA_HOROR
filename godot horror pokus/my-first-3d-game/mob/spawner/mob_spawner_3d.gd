extends Node3D

@export var mob_to_spawn: PackedScene = null
@export var max_mobs_alive: int = 500       # Maximální počet živých netopýrů z tohoto spawneru
@export var spawn_distance: float = 25.0   # Spawnuje se, jen když je hráč blíž než 25m

@onready var marker_3d: Marker3D = %Marker3D
@onready var timer: Timer = %Timer

var current_mobs_alive: int = 0            # Aktuální počet živých netopýrů
var player: Node3D

# ARITMETICKÁ POSLOUPNOST: a(1) = 0
var aktualni_vlna_pocet: int = 0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_timer_timeout() -> void:
	# Kontrola 1: Existuje hráč?
	if not player: return
	
	# Kontrola 2: Je hráč dostatečně blízko?
	var distance = global_position.distance_to(player.global_position)
	if distance > spawn_distance:
		return 

	# Aplikujeme aritmetickou posloupnost: a(n+1) = a(n) + 1
	# Při prvním tiku (n=1) se hodnota zvýší z původních 0 na 1, atd.
	# POZNÁMKA: Pokud chceš striktně začít na 0 v prvním tiku, posuň tento řádek na úplný konec této funkce.
	aktualni_vlna_pocet += 1
	print("--- ZAČÍNÁ NOVÁ VLNA. Počet mobů k vygenerování: ", aktualni_vlna_pocet, " ---")
		
	# Smyčka vygeneruje přesně tolik mobů, kolik určuje aktuální krok posloupnosti
	for i in range(aktualni_vlna_pocet):
		
		# Kontrola 3: Pokud během spawnování vlny dosáhneme absolutního limitu, stopneme to
		if current_mobs_alive >= max_mobs_alive:
			print("Dosažen maximální limit živých mobů (", max_mobs_alive, "). Spawnování přerušeno.")
			break

		# Vytvoření a nastavení moba (Správně odsazené uvnitř for cyklu)
		var new_mob = mob_to_spawn.instantiate()
		get_tree().current_scene.add_child(new_mob)
		new_mob.global_position = marker_3d.global_position
		
		current_mobs_alive += 1
		
		# Propojení signálu pro odečtení po smrti
		new_mob.tree_exited.connect(_on_mob_destroyed)

# Tato funkce se zavolá sama, jakmile netopýr zavolá queue_free()
func _on_mob_destroyed() -> void:
	current_mobs_alive -= 1
