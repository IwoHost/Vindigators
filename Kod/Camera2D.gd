extends Camera2D

var player : Node2D = null
var fixed_y : float

@export var smooth_speed : float = 5.0 
@export var look_ahead_distance : float = 250.0 # Jak daleko kamera patrzy w przód
@export var look_ahead_speed : float = 3.0    # Jak szybko kamera przesuwa się na boki

var current_offset : float = 0.0

func _ready():
	fixed_y = global_position.y
	
	var players = get_tree().get_nodes_in_group("gracz")
	if players.size() > 0:
		player = players[0]
	
	set_as_top_level(true)

func _physics_process(delta):
	if player:
		# 1. OBLICZAMY OFFSET (WYCHYLENIE)
		# Sprawdzamy kierunek z Twojego skryptu gracza
		var direction = player.kierunek_patrzenia # Używamy zmiennej z CharacterBody2D
		
		# Docelowy offset to kierunek * dystans
		var target_offset = direction * look_ahead_distance
		
		# Dodatkowy bonus do dystansu, jeśli gracz dashuje
		if player.dash.is_dashing:
			target_offset *= 1.5
		
		# Płynnie zmieniamy obecny offset (żeby kamera nie skakała przy zmianie stron)
		current_offset = lerp(current_offset, target_offset, look_ahead_speed * delta)
		
		# 2. OBLICZAMY FINALNY CEL
		var target_x = player.global_position.x + current_offset
		
		# 3. RUCH KAMERY
		global_position.x = lerp(global_position.x, target_x, smooth_speed * delta)
		
		# Y pozostaje niewzruszone
		global_position.y = fixed_y
