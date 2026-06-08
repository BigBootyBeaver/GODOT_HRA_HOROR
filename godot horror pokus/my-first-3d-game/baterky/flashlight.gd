extends Node3D

# Pomocná proměnná, která si pamatuje, zda je baterka zapnutá
var baterka_zapnuta: bool = false

func _input(event: InputEvent) -> void:
	# Zareaguje pouze v moment stisknutí tlačítka
	if Input.is_action_just_pressed("Toggle"):
		# Přepne stav: pokud byla zapnutá, vypne se. Pokud byla vypnutá, zapne se.
		baterka_zapnuta = !baterka_zapnuta
	
	# Kontrola svícení (musí být zapnutá a zároveň mít energii)
	if baterka_zapnuta and $Battery.value > 0:
		$SpotLight3D.light_energy = 48
	else: 
		$SpotLight3D.light_energy = 0

func _physics_process(delta):
	if $SpotLight3D.light_energy == 48:
		$Battery.value -= 1
		
		# Pojistka: pokud energie klesne na 0, baterku vnitřně vypneme
		if $Battery.value <= 0:
			baterka_zapnuta = false
			$SpotLight3D.light_energy = 0
